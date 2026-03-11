# MistakeNote 테스트 Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** MistakeNote 모듈에 유닛 테스트(Swift Testing)와 스냅샷 테스트(SnapshotTesting)를 Account 모듈과 동일한 패턴으로 추가한다.

**Architecture:** `@Published ObservableObject` 패턴 ViewModel은 메서드 호출 후 `@Published` 프로퍼티를 직접 읽어 검증한다. `viewDidLoad()`처럼 내부에서 `Task { }` 를 생성하는 메서드는 Account 모듈과 동일하게 `Task.sleep(nanoseconds: 100_000_000)` 로 완료를 기다린다. 스냅샷은 UIHostingController를 iPhone 16 Pro 크기(393×852)로 고정해 찍는다.

**Tech Stack:** Swift Testing, XCTest, SnapshotTesting 1.18.9+, SwiftUI UIHostingController

---

## Chunk 1: Package.swift + 인프라 파일

### Task 1: Package.swift에 테스트 타겟 추가

**Files:**
- Modify: `MistakeNote/Package.swift`

- [ ] **Step 1: Package.swift 수정**

```swift
// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MistakeNote",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "MistakeNote", targets: ["MistakeNote"]),
    ],
    dependencies: [
        .package(path: "../Network"),
        .package(path: "../DesignSystem"),
        .package(path: "../QRIZUtils"),
        .package(path: "../Conceptbook"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.18.9"),
    ],
    targets: [
        .target(
            name: "MistakeNote",
            dependencies: [
                "Network",
                "DesignSystem",
                "QRIZUtils",
                "Conceptbook",
            ]
        ),
        .testTarget(
            name: "MistakeNoteTests",
            dependencies: [
                "MistakeNote",
                "Network",
                "QRIZUtils",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ]
        ),
    ]
)
```

- [ ] **Step 2: 빌드 확인**

```bash
cd /Users/hun/iOS/MistakeNote && swift build
```
Expected: Build succeeded

- [ ] **Step 3: 커밋**

```bash
git add MistakeNote/Package.swift
git commit -m "config: MistakeNoteTests 타겟 및 SnapshotTesting 의존성 추가"
```

---

### Task 2: 인프라 파일 생성

**Files:**
- Create: `MistakeNote/Tests/MistakeNoteTests/Mocks/MockMistakeNoteService.swift`
- Create: `MistakeNote/Tests/MistakeNoteTests/Mocks/SnapshotServiceStubs.swift`
- Create: `MistakeNote/Tests/MistakeNoteTests/TestHelpers.swift`
- Create: `MistakeNote/Tests/MistakeNoteTests/SnapshotTestHelpers.swift`

- [ ] **Step 1: MockMistakeNoteService 생성**

`Network`는 public 라이브러리 타겟이므로 `import Network` 로 임포트한다 (`@testable` 불필요).

```swift
// MistakeNote/Tests/MistakeNoteTests/Mocks/MockMistakeNoteService.swift

import Foundation
import Network

final class MockMistakeNoteService: MistakeNoteService, @unchecked Sendable {

    var completedDaysResult: Result<CompletedDailyDaysResponse, Error> = .success(
        CompletedDailyDaysResponse(code: 1, msg: "ok", data: .init(days: ["Day1", "Day2", "Day3"]))
    )

    var completedExamSessionsResult: Result<CompletedExamSessionsResponse, Error> = .success(
        CompletedExamSessionsResponse(
            code: 1, msg: "ok",
            data: .init(sessions: ["1회차", "2회차", "3회차"], latestSession: "3회차")
        )
    )

    var clipsResult: Result<ClipsResponse, Error> = .success(
        ClipsResponse(code: 1, msg: "ok", data: [])
    )

    var clipDetailResult: Result<ClipDetailResponse, Error> = .success(
        ClipDetailResponse(
            code: 1, msg: "ok",
            data: DailyResultDetail(
                skillName: "SQL 기본",
                questionText: "테스트 문제",
                questionNum: 1,
                description: nil,
                option1: "1번",
                option2: "2번",
                option3: "3번",
                option4: "4번",
                answer: 1,
                solution: "해설",
                checked: 2,
                correction: false,
                testInfo: "Day1",
                skillId: 1,
                title: "1과목",
                keyConcepts: "SELECT문"
            )
        )
    )

    func getCompletedDays() async throws -> CompletedDailyDaysResponse {
        try completedDaysResult.get()
    }

    func getCompletedExamSessions() async throws -> CompletedExamSessionsResponse {
        try completedExamSessionsResult.get()
    }

    func getClips(category: Int?, testInfo: String?) async throws -> ClipsResponse {
        try clipsResult.get()
    }

    func getClipDetail(clipId: Int) async throws -> ClipDetailResponse {
        try clipDetailResult.get()
    }
}
```

- [ ] **Step 2: SnapshotServiceStubs 생성**

```swift
// MistakeNote/Tests/MistakeNoteTests/Mocks/SnapshotServiceStubs.swift

import Foundation
import Network

final class StubMistakeNoteService: MistakeNoteService, @unchecked Sendable {
    func getCompletedDays() async throws -> CompletedDailyDaysResponse { fatalError("stub") }
    func getCompletedExamSessions() async throws -> CompletedExamSessionsResponse { fatalError("stub") }
    func getClips(category: Int?, testInfo: String?) async throws -> ClipsResponse { fatalError("stub") }
    func getClipDetail(clipId: Int) async throws -> ClipDetailResponse { fatalError("stub") }
}
```

- [ ] **Step 3: TestHelpers 생성**

`MistakeNoteQuestion`은 `MistakeNote`에, `DailyResultDetailEntity`는 `QRIZUtils`에 정의되어 있다.

```swift
// MistakeNote/Tests/MistakeNoteTests/TestHelpers.swift

import Foundation
@testable import MistakeNote
import QRIZUtils

// MARK: - Test Fixtures

extension MistakeNoteQuestion {
    static func make(
        id: Int = 1,
        questionNum: Int = 1,
        question: String = "테스트 문제",
        correction: Bool = false,
        keyConcepts: String = "SELECT문",
        date: String = "2026-01-01"
    ) -> MistakeNoteQuestion {
        MistakeNoteQuestion(
            id: id,
            questionNum: questionNum,
            question: question,
            correction: correction,
            keyConcepts: keyConcepts,
            date: date
        )
    }
}

extension DailyResultDetailEntity {
    static func make(
        skillName: String = "SQL 기본",
        questionText: String = "테스트 문제",
        questionNum: Int = 1,
        description: String? = nil,
        option1: String = "1번",
        option2: String = "2번",
        option3: String = "3번",
        option4: String = "4번",
        answer: Int = 1,
        solution: String = "해설",
        checked: Int? = 2,
        correction: Bool = false,
        testInfo: String = "Day1",
        skillId: Int = 1,
        title: String = "1과목",
        keyConcepts: String = "SELECT문"
    ) -> DailyResultDetailEntity {
        DailyResultDetailEntity(
            skillName: skillName,
            questionText: questionText,
            questionNum: questionNum,
            description: description,
            option1: option1,
            option2: option2,
            option3: option3,
            option4: option4,
            answer: answer,
            solution: solution,
            checked: checked,
            correction: correction,
            testInfo: testInfo,
            skillId: skillId,
            title: title,
            keyConcepts: keyConcepts
        )
    }
}
```

- [ ] **Step 4: SnapshotTestHelpers 생성**

`@MainActor class XCTestCase` 패턴은 Account 모듈과 동일하게 사용한다.

```swift
// MistakeNote/Tests/MistakeNoteTests/SnapshotTestHelpers.swift

import UIKit
import XCTest

@MainActor
class MistakeNoteSnapshotTestCase: XCTestCase {
    static let deviceSize = CGSize(width: 393, height: 852) // iPhone 16 Pro
}
```

- [ ] **Step 5: 빌드 확인**

```bash
cd /Users/hun/iOS/MistakeNote && swift test --build-only 2>&1 | head -30
```
Expected: Build succeeded (테스트 실행 없이 컴파일만 검증)

- [ ] **Step 6: 커밋**

```bash
git add MistakeNote/Tests/
git commit -m "test: MistakeNote 테스트 인프라 파일 추가 (Mock, Stub, Helpers)"
```

---

## Chunk 2: 유닛 테스트

### Task 3: SubjectFilterSheetViewModelTests

**Files:**
- Create: `MistakeNote/Tests/MistakeNoteTests/UnitTests/SubjectFilterSheetViewModelTests.swift`

SubjectFilterSheetViewModel은 네트워크 없이 순수 로직만 테스트한다.

- [ ] **Step 1: 테스트 파일 생성**

```swift
// MistakeNote/Tests/MistakeNoteTests/UnitTests/SubjectFilterSheetViewModelTests.swift

import Testing
@testable import MistakeNote
import QRIZUtils

@MainActor
@Suite("SubjectFilterSheetViewModel 테스트", .serialized)
struct SubjectFilterSheetViewModelTests {

    private func makeSUT(
        availableConcepts: Set<String> = [],
        initialSubject: Subject = .one,
        initialSelectedConcepts: Set<String> = []
    ) -> SubjectFilterSheetViewModel {
        SubjectFilterSheetViewModel(
            availableConcepts: availableConcepts,
            initialSubject: initialSubject,
            initialSelectedConcepts: initialSelectedConcepts
        )
    }

    // MARK: - hasSelections

    @Test("selectedConcepts 비어있을 때 hasSelections는 false")
    func hasSelections_false_whenEmpty() {
        let sut = makeSUT()
        #expect(sut.hasSelections == false)
    }

    @Test("selectedConcepts 있을 때 hasSelections는 true")
    func hasSelections_true_whenNotEmpty() {
        let sut = makeSUT(initialSelectedConcepts: ["SELECT문"])
        #expect(sut.hasSelections == true)
    }

    // MARK: - hasChanges

    @Test("초기값과 동일하면 hasChanges는 false")
    func hasChanges_false_whenSameAsInitial() {
        let sut = makeSUT(initialSelectedConcepts: ["SELECT문"])
        #expect(sut.hasChanges == false)
    }

    @Test("selectedConcepts 변경하면 hasChanges는 true")
    func hasChanges_true_whenDifferentFromInitial() {
        let sut = makeSUT(initialSelectedConcepts: ["SELECT문"])
        sut.selectedConcepts = ["WHERE절"]
        #expect(sut.hasChanges == true)
    }

    // MARK: - reset

    @Test("reset() 호출 시 selectedConcepts 비워짐")
    func reset_clearsSelectedConcepts() {
        let sut = makeSUT(initialSelectedConcepts: ["SELECT문"])
        sut.reset()
        #expect(sut.selectedConcepts.isEmpty)
    }

    // MARK: - availableChapters

    @Test("availableConcepts에 포함된 chapter만 반환")
    func availableChapters_onlyIncludesChaptersWithAvailableConcepts() {
        let firstChapter = Subject.one.chapters[0]
        let conceptInFirstChapter = firstChapter.concepts[0]

        let sut = makeSUT(
            availableConcepts: [conceptInFirstChapter],
            initialSubject: .one
        )

        #expect(sut.availableChapters.contains(firstChapter))
    }

    @Test("availableConcepts가 비어있으면 availableChapters도 비어있음")
    func availableChapters_emptyWhenNoAvailableConcepts() {
        let sut = makeSUT(availableConcepts: [], initialSubject: .one)
        #expect(sut.availableChapters.isEmpty)
    }
}
```

- [ ] **Step 2: 테스트 실행 확인**

```bash
cd /Users/hun/iOS/MistakeNote && swift test --filter SubjectFilterSheetViewModelTests 2>&1 | tail -20
```
Expected: 6개 테스트 모두 PASS

- [ ] **Step 3: 커밋**

```bash
git add MistakeNote/Tests/MistakeNoteTests/UnitTests/SubjectFilterSheetViewModelTests.swift
git commit -m "test: SubjectFilterSheetViewModelTests 추가"
```

---

### Task 4: MistakeNoteListViewModelTests

**Files:**
- Create: `MistakeNote/Tests/MistakeNoteTests/UnitTests/MistakeNoteListViewModelTests.swift`

- [ ] **Step 1: 테스트 파일 생성**

```swift
// MistakeNote/Tests/MistakeNoteTests/UnitTests/MistakeNoteListViewModelTests.swift

import Testing
@testable import MistakeNote
import Network
import QRIZUtils

@MainActor
@Suite("MistakeNoteListViewModel 테스트", .serialized)
struct MistakeNoteListViewModelTests {

    private func makeSUT(service: MockMistakeNoteService = .init()) -> MistakeNoteListViewModel {
        MistakeNoteListViewModel(service: service)
    }

    // MARK: - displayedQuestions 필터

    @Test("필터 없을 때 displayedQuestions는 전체 반환")
    func displayedQuestions_noFilter_returnsAll() {
        let sut = makeSUT()
        sut.filteredQuestions = [
            .make(id: 1, correction: true),
            .make(id: 2, correction: false),
        ]
        #expect(sut.displayedQuestions.count == 2)
    }

    @Test("incorrectOnly 필터 적용 시 오답만 반환")
    func displayedQuestions_incorrectOnly_excludesCorrect() {
        let sut = makeSUT()
        sut.filteredQuestions = [
            .make(id: 1, correction: true),
            .make(id: 2, correction: false),
            .make(id: 3, correction: false),
        ]
        sut.filterAllChanged(.incorrectOnly)
        #expect(sut.displayedQuestions.count == 2)
        #expect(sut.displayedQuestions.allSatisfy { !$0.correction })
    }

    @Test("conceptFilter 적용 시 해당 concept 문제만 반환")
    func displayedQuestions_conceptFilter_returnsMatchingOnly() {
        let sut = makeSUT()
        sut.filteredQuestions = [
            .make(id: 1, keyConcepts: "SELECT문"),
            .make(id: 2, keyConcepts: "WHERE절"),
            .make(id: 3, keyConcepts: "SELECT문, JOIN"),
        ]
        sut.conceptFilterApplied(["SELECT문"], nil)
        #expect(sut.displayedQuestions.count == 2)
    }

    // MARK: - 필터 리셋

    @Test("tabSelected() 호출 시 모든 필터 리셋")
    func tabSelected_resetsAllFilters() {
        let sut = makeSUT()
        sut.filterAllChanged(.incorrectOnly)
        sut.conceptFilterApplied(["SELECT문"], .one)

        sut.tabSelected(.mockExam)

        #expect(sut.filterAll == .all)
        #expect(sut.selectedConceptsFilter.isEmpty)
        #expect(sut.selectedFilterSubject == nil)
    }

    @Test("daySelected() 호출 시 모든 필터 리셋")
    func daySelected_resetsAllFilters() {
        let sut = makeSUT()
        sut.filterAllChanged(.incorrectOnly)
        sut.conceptFilterApplied(["SELECT문"], .one)

        sut.daySelected("Day1")

        #expect(sut.filterAll == .all)
        #expect(sut.selectedConceptsFilter.isEmpty)
    }

    @Test("sessionSelected() 호출 시 모든 필터 리셋")
    func sessionSelected_resetsAllFilters() {
        let sut = makeSUT()
        sut.filterAllChanged(.incorrectOnly)
        sut.conceptFilterApplied(["SELECT문"], .one)

        sut.sessionSelected("1회차")

        #expect(sut.filterAll == .all)
        #expect(sut.selectedConceptsFilter.isEmpty)
    }

    // MARK: - hasFilterForSubject

    @Test("선택된 concept이 해당 subject에 속하면 true")
    func hasFilterForSubject_true_whenSubjectConceptSelected() {
        let sut = makeSUT()
        let subject = Subject.one
        let conceptInSubject = subject.chapters[0].concepts[0]
        sut.conceptFilterApplied([conceptInSubject], subject)

        #expect(sut.hasFilterForSubject(subject) == true)
    }

    @Test("선택된 concept이 없으면 false")
    func hasFilterForSubject_false_whenNoConceptSelected() {
        let sut = makeSUT()
        #expect(sut.hasFilterForSubject(.one) == false)
    }

    // MARK: - 내비게이션

    @Test("questionTapped() → onNavigate(.navigateToClipDetail)")
    func questionTapped_triggersNavigateToClipDetail() {
        let sut = makeSUT()
        var output: MistakeNoteListViewModel.Output?
        sut.onNavigate = { output = $0 }

        sut.questionTapped(.make(id: 42))

        if case .navigateToClipDetail(let clipId) = output {
            #expect(clipId == 42)
        } else {
            Issue.record("Expected navigateToClipDetail")
        }
    }

    @Test("goToExamTapped() → onNavigate(.navigateToExam)")
    func goToExamTapped_triggersNavigateToExam() {
        let sut = makeSUT()
        var output: MistakeNoteListViewModel.Output?
        sut.onNavigate = { output = $0 }
        sut.selectedTab = .mockExam

        sut.goToExamTapped()

        if case .navigateToExam(let tab) = output {
            #expect(tab == .mockExam)
        } else {
            Issue.record("Expected navigateToExam")
        }
    }

    // MARK: - 비동기 로딩

    @Test("viewDidLoad() 성공 → availableDays 설정")
    func viewDidLoad_setsAvailableDays() async {
        let service = MockMistakeNoteService()
        service.completedDaysResult = .success(
            CompletedDailyDaysResponse(code: 1, msg: "ok", data: .init(days: ["Day1", "Day2"]))
        )
        service.clipsResult = .success(ClipsResponse(code: 1, msg: "ok", data: []))
        let sut = makeSUT(service: service)

        await sut.viewDidLoad()

        #expect(sut.availableDays == ["Day1", "Day2"])
        #expect(sut.selectedDay == "Day1")
        #expect(!sut.isLoading)
    }

    @Test("viewDidLoad() 실패 → errorMessage 설정")
    func viewDidLoad_setsErrorMessage_onFailure() async {
        let service = MockMistakeNoteService()
        service.completedDaysResult = .failure(URLError(.notConnectedToInternet))
        let sut = makeSUT(service: service)

        await sut.viewDidLoad()

        #expect(sut.errorMessage != nil)
        #expect(!sut.isLoading)
    }
}
```

- [ ] **Step 2: 테스트 실행 확인**

```bash
cd /Users/hun/iOS/MistakeNote && swift test --filter MistakeNoteListViewModelTests 2>&1 | tail -20
```
Expected: 11개 테스트 모두 PASS

- [ ] **Step 3: 커밋**

```bash
git add MistakeNote/Tests/MistakeNoteTests/UnitTests/MistakeNoteListViewModelTests.swift
git commit -m "test: MistakeNoteListViewModelTests 추가"
```

---

### Task 5: ProblemDetailViewModelTests

**Files:**
- Create: `MistakeNote/Tests/MistakeNoteTests/UnitTests/ProblemDetailViewModelTests.swift`

`ProblemDetailViewModel.viewDidLoad()`는 내부에서 `Task { }` 를 생성하므로 `await` 직접 호출 불가.
Account 모듈과 동일하게 `Task.sleep(nanoseconds: 100_000_000)` 으로 완료를 기다린다.

- [ ] **Step 1: 테스트 파일 생성**

```swift
// MistakeNote/Tests/MistakeNoteTests/UnitTests/ProblemDetailViewModelTests.swift

import Testing
@testable import MistakeNote
import QRIZUtils

@MainActor
@Suite("ProblemDetailViewModel 테스트", .serialized)
struct ProblemDetailViewModelTests {

    private func makeSUT(
        fetchResult: Result<DailyResultDetailEntity, Error> = .success(.make())
    ) -> ProblemDetailViewModel {
        ProblemDetailViewModel {
            try fetchResult.get()
        }
    }

    // MARK: - 내비게이션

    @Test("learnButtonTapped() → onNavigate(.navigateToConceptTab)")
    func learnButtonTapped_triggersNavigateToConceptTab() {
        let sut = makeSUT()
        var output: ProblemDetailViewModel.Output?
        sut.onNavigate = { output = $0 }

        sut.learnButtonTapped()

        if case .navigateToConceptTab = output {
            // pass
        } else {
            Issue.record("Expected navigateToConceptTab")
        }
    }

    @Test("존재하는 concept tap → navigateToConceptDetail")
    func conceptTapped_existingConcept_triggersNavigateToConceptDetail() {
        let sut = makeSUT()
        var output: ProblemDetailViewModel.Output?
        sut.onNavigate = { output = $0 }

        let existingConcept = Chapter.allCases[0].conceptItems[0].title
        sut.conceptTapped(concept: existingConcept)

        if case .navigateToConceptDetail = output {
            // pass
        } else {
            Issue.record("Expected navigateToConceptDetail for concept: \(existingConcept)")
        }
    }

    @Test("존재하지 않는 concept tap → onNavigate 미호출")
    func conceptTapped_unknownConcept_doesNotTriggerNavigate() {
        let sut = makeSUT()
        var navigateCalled = false
        sut.onNavigate = { _ in navigateCalled = true }

        sut.conceptTapped(concept: "존재하지않는개념XYZ")

        #expect(navigateCalled == false)
    }

    // MARK: - 비동기 로딩

    @Test("viewDidLoad() 성공 → problemDetail 설정")
    func viewDidLoad_setsProblemDetail() async {
        let entity = DailyResultDetailEntity.make(questionText: "실제 문제")
        let sut = makeSUT(fetchResult: .success(entity))

        sut.viewDidLoad()
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(sut.problemDetail?.questionText == "실제 문제")
        #expect(!sut.isLoading)
    }

    @Test("viewDidLoad() 실패 → errorMessage 설정")
    func viewDidLoad_setsErrorMessage_onFailure() async {
        let sut = makeSUT(fetchResult: .failure(URLError(.notConnectedToInternet)))

        sut.viewDidLoad()
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(sut.errorMessage != nil)
        #expect(!sut.isLoading)
    }

    @Test("retry() 호출 후 성공 → problemDetail 설정")
    func retry_afterFailure_setsProblemDetail() async {
        var callCount = 0
        let sut = ProblemDetailViewModel {
            callCount += 1
            if callCount == 1 { throw URLError(.notConnectedToInternet) }
            return .make(questionText: "재시도 성공")
        }

        sut.viewDidLoad()
        try? await Task.sleep(nanoseconds: 100_000_000)
        #expect(sut.errorMessage != nil)

        sut.retry()
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(sut.problemDetail?.questionText == "재시도 성공")
        #expect(sut.errorMessage == nil)
    }
}
```

- [ ] **Step 2: 테스트 실행 확인**

```bash
cd /Users/hun/iOS/MistakeNote && swift test --filter ProblemDetailViewModelTests 2>&1 | tail -20
```
Expected: 6개 테스트 모두 PASS

- [ ] **Step 3: 커밋**

```bash
git add MistakeNote/Tests/MistakeNoteTests/UnitTests/ProblemDetailViewModelTests.swift
git commit -m "test: ProblemDetailViewModelTests 추가"
```

---

## Chunk 3: 스냅샷 테스트

### Task 6: MistakeNoteSnapshotTests

**Files:**
- Create: `MistakeNote/Tests/MistakeNoteTests/SnapshotTests/MistakeNoteSnapshotTests.swift`

- [ ] **Step 1: 테스트 파일 생성**

```swift
// MistakeNote/Tests/MistakeNoteTests/SnapshotTests/MistakeNoteSnapshotTests.swift

import XCTest
import SnapshotTesting
@testable import MistakeNote

@MainActor
class MistakeNoteSnapshotTests: MistakeNoteSnapshotTestCase {

    func testInitialState() {
        let vm = MistakeNoteListViewModel(service: StubMistakeNoteService())
        let vc = MistakeNoteViewController(viewModel: vm)
        vc.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        vc.view.layoutIfNeeded()

        assertSnapshot(of: vc, as: .image)
    }
}
```

- [ ] **Step 2: 레퍼런스 이미지 생성 (record 모드)**

`assertSnapshot` 을 `assertSnapshot(of: vc, as: .image, record: .all)` 로 변경 후 실행:
```bash
cd /Users/hun/iOS/MistakeNote && swift test --filter MistakeNoteSnapshotTests 2>&1 | tail -20
```
Expected: `__Snapshots__` 폴더에 레퍼런스 이미지 생성됨

- [ ] **Step 3: record 모드 제거 후 재실행**

`record: .all` 제거 후:
```bash
cd /Users/hun/iOS/MistakeNote && swift test --filter MistakeNoteSnapshotTests 2>&1 | tail -20
```
Expected: PASS

- [ ] **Step 4: 커밋**

```bash
git add MistakeNote/Tests/
git commit -m "test: MistakeNoteSnapshotTests 추가"
```

---

### Task 7: ProblemDetailSnapshotTests

**Files:**
- Create: `MistakeNote/Tests/MistakeNoteTests/SnapshotTests/ProblemDetailSnapshotTests.swift`

- [ ] **Step 1: 테스트 파일 생성**

```swift
// MistakeNote/Tests/MistakeNoteTests/SnapshotTests/ProblemDetailSnapshotTests.swift

import XCTest
import SnapshotTesting
@testable import MistakeNote

@MainActor
class ProblemDetailSnapshotTests: MistakeNoteSnapshotTestCase {

    func testLoadingState() {
        // fetchDetail이 절대 완료되지 않는 ViewModel → 로딩 상태 유지
        let vm = ProblemDetailViewModel {
            try await Task.sleep(nanoseconds: 999_999_999_999)
            throw URLError(.cancelled)
        }
        let vc = ProblemDetailViewController(viewModel: vm)
        vc.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        vc.view.layoutIfNeeded()

        assertSnapshot(of: vc, as: .image)
    }
}
```

- [ ] **Step 2: 레퍼런스 이미지 생성 (record 모드)**

`assertSnapshot(of: vc, as: .image, record: .all)` 로 변경 후:
```bash
cd /Users/hun/iOS/MistakeNote && swift test --filter ProblemDetailSnapshotTests 2>&1 | tail -20
```

- [ ] **Step 3: record 모드 제거 후 재실행**

```bash
cd /Users/hun/iOS/MistakeNote && swift test --filter ProblemDetailSnapshotTests 2>&1 | tail -20
```
Expected: PASS

- [ ] **Step 4: 커밋**

```bash
git add MistakeNote/Tests/
git commit -m "test: ProblemDetailSnapshotTests 추가"
```

---

### Task 8: SubjectFilterSheetSnapshotTests

**Files:**
- Create: `MistakeNote/Tests/MistakeNoteTests/SnapshotTests/SubjectFilterSheetSnapshotTests.swift`

- [ ] **Step 1: 테스트 파일 생성**

```swift
// MistakeNote/Tests/MistakeNoteTests/SnapshotTests/SubjectFilterSheetSnapshotTests.swift

import XCTest
import SnapshotTesting
import SwiftUI
@testable import MistakeNote
import QRIZUtils

@MainActor
class SubjectFilterSheetSnapshotTests: MistakeNoteSnapshotTestCase {

    private func makeVC(
        availableConcepts: Set<String> = ["SELECT문", "WHERE절", "JOIN", "서브쿼리"],
        initialSelectedConcepts: Set<String> = []
    ) -> UIViewController {
        let view = SubjectFilterSheet(
            isPresented: .constant(true),
            availableConcepts: availableConcepts,
            initialSubject: .one,
            initialSelectedConcepts: initialSelectedConcepts
        )
        return UIHostingController(rootView: view)
    }

    func testInitialState() {
        let vc = makeVC()
        vc.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        vc.view.layoutIfNeeded()

        assertSnapshot(of: vc, as: .image)
    }

    func testWithSelectedConcepts() {
        let vc = makeVC(initialSelectedConcepts: ["SELECT문", "WHERE절"])
        vc.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        vc.view.layoutIfNeeded()

        assertSnapshot(of: vc, as: .image)
    }
}
```

- [ ] **Step 2: 레퍼런스 이미지 생성 (record 모드)**

두 `assertSnapshot` 호출에 `record: .all` 추가 후:
```bash
cd /Users/hun/iOS/MistakeNote && swift test --filter SubjectFilterSheetSnapshotTests 2>&1 | tail -20
```

- [ ] **Step 3: record 모드 제거 후 재실행**

```bash
cd /Users/hun/iOS/MistakeNote && swift test --filter SubjectFilterSheetSnapshotTests 2>&1 | tail -20
```
Expected: 2개 테스트 모두 PASS

- [ ] **Step 4: 전체 테스트 실행 최종 확인**

```bash
cd /Users/hun/iOS/MistakeNote && swift test 2>&1 | tail -30
```
Expected: 전체 테스트 PASS

- [ ] **Step 5: 커밋**

```bash
git add MistakeNote/Tests/
git commit -m "test: SubjectFilterSheetSnapshotTests 추가"
```
