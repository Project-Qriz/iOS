# MistakeNote SPM 모듈화 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** App 타겟에 위치한 MistakeNote 피처를 `MistakeNote` SPM 로컬 패키지로 분리한다.

**Architecture:** MistakeNoteList + ProblemExplanation + Coordinator를 단일 `MistakeNote` 패키지로 이동. App 타겟의 TabBarCoordinator는 `import MistakeNote`로 교체.

**Tech Stack:** Swift 6.0, SPM local package, iOS 17.0, Combine, SwiftUI

---

### Task 1: Package.swift 및 디렉토리 구조 생성

**Files:**
- Create: `MistakeNote/Package.swift`
- Create: `MistakeNote/Sources/MistakeNote/` (디렉토리)

**Step 1: Package.swift 생성**

```swift
// MistakeNote/Package.swift
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
    ]
)
```

**Step 2: 디렉토리 구조 생성**

```bash
mkdir -p MistakeNote/Sources/MistakeNote/Coordinator
mkdir -p MistakeNote/Sources/MistakeNote/MistakeNoteList/View/SubjectFilterSheet
mkdir -p MistakeNote/Sources/MistakeNote/MistakeNoteList/ViewModel
mkdir -p MistakeNote/Sources/MistakeNote/MistakeNoteList/ViewController
mkdir -p MistakeNote/Sources/MistakeNote/ProblemExplanation/View
mkdir -p MistakeNote/Sources/MistakeNote/ProblemExplanation/ViewModel
mkdir -p MistakeNote/Sources/MistakeNote/ProblemExplanation/ViewController
```

**Step 3: Commit**

```bash
git add MistakeNote/
git commit -m "config: MistakeNote SPM 패키지 초기 구성"
```

---

### Task 2: Coordinator 이동

**Files:**
- Copy → Modify: `QRIZ/Feature/MistakeNote/MistakeNoteCoordinator.swift` → `MistakeNote/Sources/MistakeNote/Coordinator/MistakeNoteCoordinator.swift`

**Step 1: 파일 복사 후 수정**

`QRIZ/Feature/MistakeNote/MistakeNoteCoordinator.swift`를 복사해 아래 변경 적용:

- `import UIKit` 유지
- `import QRIZUtils`, `import Network`, `import Conceptbook` 유지
- 모든 `public` 접근 제어자 추가:
  - `public protocol MistakeNoteCoordinator`
  - `public protocol MistakeNoteCoordinatorDelegate`
  - `public final class MistakeNoteCoordinatorImpl`
  - `public init(service: MistakeNoteService = MistakeNoteServiceImpl())`
  - `public func start()`
  - `public func showClipDetail(clipId: Int)`
  - `public var delegate`
  - `public var childCoordinators`
  - `public var isNavigating`

**Step 2: Commit**

```bash
git add MistakeNote/Sources/MistakeNote/Coordinator/
git commit -m "refactor: MistakeNoteCoordinator 패키지로 이동"
```

---

### Task 3: MistakeNoteList View 이동

**Files:**
- 이동 대상 (각 파일을 `MistakeNote/Sources/MistakeNote/MistakeNoteList/View/`로 복사):
  - `QRIZ/Feature/MistakeNote/MistakeNoteList/View/DaySelectDropdownButton.swift`
  - `QRIZ/Feature/MistakeNote/MistakeNoteList/View/FilterChipButton.swift`
  - `QRIZ/Feature/MistakeNote/MistakeNoteList/View/MistakeNoteEmptyView.swift`
  - `QRIZ/Feature/MistakeNote/MistakeNoteList/View/MistakeNoteMainView.swift`
  - `QRIZ/Feature/MistakeNote/MistakeNoteList/View/MistakeNoteNoRecordView.swift`
  - `QRIZ/Feature/MistakeNote/MistakeNoteList/View/MistakeNoteQuestionCard.swift`
  - `QRIZ/Feature/MistakeNote/MistakeNoteList/View/MistakeNoteQuestionListView.swift`  ← `MistakeNoteQuestion` struct 포함
  - `QRIZ/Feature/MistakeNote/MistakeNoteList/View/MistakeNoteTabSelector.swift`  ← `MistakeNoteTab` enum 포함
  - `QRIZ/Feature/MistakeNote/MistakeNoteList/View/SubjectFilterSheet/FilterChip.swift`
  - `QRIZ/Feature/MistakeNote/MistakeNoteList/View/SubjectFilterSheet/FilterSectionView.swift`
  - `QRIZ/Feature/MistakeNote/MistakeNoteList/View/SubjectFilterSheet/SubjectFilterSheet.swift`

**Step 1: 각 파일 복사 후 public 추가**

파일 상단 `import` 아래 타입 선언에 `public` 추가. 규칙:
- `enum`, `struct`, `class`, `protocol` → `public`
- `init` → `public`
- `body`, `var`, `func` (외부에서 접근 필요한 것) → `public`
- SwiftUI View의 `body`는 반드시 `public`

`MistakeNoteTab` (MistakeNoteTabSelector.swift 내):
```swift
public enum MistakeNoteTab: String, CaseIterable, Sendable {
    case daily = "데일리"
    case mockExam = "모의고사"
}
```

`MistakeNoteQuestion` (MistakeNoteQuestionListView.swift 내):
```swift
public struct MistakeNoteQuestion: Identifiable, Decodable, Sendable {
    public let id: Int
    public let questionNum: Int
    public let question: String
    public let correction: Bool
    public let keyConcepts: String
    public let date: String
}
```

**Step 2: Commit**

```bash
git add MistakeNote/Sources/MistakeNote/MistakeNoteList/View/
git commit -m "refactor: MistakeNoteList View 패키지로 이동"
```

---

### Task 4: MistakeNoteList ViewController 이동

**Files:**
- Copy → Modify: `QRIZ/Feature/MistakeNote/MistakeNoteList/ViewController/MistakeNoteViewController.swift` → `MistakeNote/Sources/MistakeNote/MistakeNoteList/ViewController/MistakeNoteViewController.swift`

**Step 1: 파일 복사 후 public 추가**

- `public protocol MistakeNoteViewControllerDelegate`
- `public final class MistakeNoteViewController`
- `public weak var delegate`
- `public init(viewModel: MistakeNoteListViewModel)`
- `@MainActor required dynamic public init?(coder aDecoder: NSCoder)`

**Step 2: Commit**

```bash
git add MistakeNote/Sources/MistakeNote/MistakeNoteList/ViewController/
git commit -m "refactor: MistakeNoteViewController 패키지로 이동"
```

---

### Task 5: MistakeNoteList ViewModel 이동

**Files:**
- Copy → Modify: `QRIZ/Feature/MistakeNote/MistakeNoteList/ViewModel/MistakeNoteListViewModel.swift` → `MistakeNote/Sources/MistakeNote/MistakeNoteList/ViewModel/MistakeNoteListViewModel.swift`
- Copy → Modify: `QRIZ/Feature/MistakeNote/MistakeNoteList/ViewModel/SubjectFilterSheetViewModel.swift` → `MistakeNote/Sources/MistakeNote/MistakeNoteList/ViewModel/SubjectFilterSheetViewModel.swift`

**Step 1: MistakeNoteListViewModel 복사 후 public 추가**

- `public final class MistakeNoteListViewModel`
- `public enum Input`
- `public enum Output`
- 모든 `@Published` 프로퍼티 → `public`
- 모든 computed properties → `public`
- `public init(service: MistakeNoteService = MistakeNoteServiceImpl())`
- `public func transform(input:)` → `public`
- `public func hasFilterForSubject(_:)` → `public`

**Step 2: SubjectFilterSheetViewModel 복사 후 public 추가**

- `public final class SubjectFilterSheetViewModel`
- `public enum Input`
- 모든 `@Published` 프로퍼티 → `public`
- 모든 `let` 프로퍼티 (availableConcepts 등) → `public`
- computed properties → `public`
- `public init(...)`
- `public func send(_:)`
- `public func normalizeConceptName(_:)`

**Step 3: Commit**

```bash
git add MistakeNote/Sources/MistakeNote/MistakeNoteList/ViewModel/
git commit -m "refactor: MistakeNoteList ViewModel 패키지로 이동"
```

---

### Task 6: ProblemExplanation View 이동

**Files:**
- 이동 대상 (`MistakeNote/Sources/MistakeNote/ProblemExplanation/View/`로 복사):
  - `QRIZ/Feature/MistakeNote/ProblemExplanation/View/ProblemDetailView.swift`
  - `QRIZ/Feature/MistakeNote/ProblemExplanation/View/ProblemHeaderCardView.swift`
  - `QRIZ/Feature/MistakeNote/ProblemExplanation/View/ProblemKeyConceptsView.swift`
  - `QRIZ/Feature/MistakeNote/ProblemExplanation/View/ProblemOptionView.swift`
  - `QRIZ/Feature/MistakeNote/ProblemExplanation/View/ProblemQuestionSectionView.swift`
  - `QRIZ/Feature/MistakeNote/ProblemExplanation/View/ProblemResultView.swift`
  - `QRIZ/Feature/MistakeNote/ProblemExplanation/View/ProblemSolutionView.swift`

**Step 1: 각 파일 복사 후 public 추가**

SwiftUI View는 다음 패턴:
```swift
public struct ProblemDetailView: View {
    // ...
    public init(...) { ... }
    public var body: some View { ... }
}
```

**Step 2: Commit**

```bash
git add MistakeNote/Sources/MistakeNote/ProblemExplanation/View/
git commit -m "refactor: ProblemExplanation View 패키지로 이동"
```

---

### Task 7: ProblemExplanation ViewController + ViewModel 이동

**Files:**
- Copy → Modify: `QRIZ/Feature/MistakeNote/ProblemExplanation/ViewController/ProblemDetailViewController.swift` → `MistakeNote/Sources/MistakeNote/ProblemExplanation/ViewController/ProblemDetailViewController.swift`
- Copy → Modify: `QRIZ/Feature/MistakeNote/ProblemExplanation/ViewModel/ProblemDetailViewModel.swift` → `MistakeNote/Sources/MistakeNote/ProblemExplanation/ViewModel/ProblemDetailViewModel.swift`

**Step 1: ProblemDetailViewModel 복사 후 public 추가**

- `public final class ProblemDetailViewModel`
- `public enum Input`
- `public enum Output`
- 모든 `@Published` → `public`
- `public init(fetchDetail: @escaping () async throws -> DailyResultDetailEntity)`
- `public func transform(input:)`

**Step 2: ProblemDetailViewController 복사 후 public 추가**

- `public protocol ProblemDetailCoordinating`
- `public final class ProblemDetailViewController`
- `public weak var coordinator`
- `public init(viewModel: ProblemDetailViewModel)`
- `@MainActor required dynamic public init?(coder:)`

**Step 3: Commit**

```bash
git add MistakeNote/Sources/MistakeNote/ProblemExplanation/
git commit -m "refactor: ProblemExplanation ViewController/ViewModel 패키지로 이동"
```

---

### Task 8: Xcode 프로젝트에 패키지 연결

**Files:**
- Modify: `QRIZ.xcodeproj` (Xcode GUI 작업)

**Step 1: Xcode에서 패키지 추가**

1. Xcode에서 `QRIZ.xcodeproj` 열기
2. Project Navigator에서 QRIZ 프로젝트 선택
3. QRIZ 타겟 선택 → **General** 탭
4. **Frameworks, Libraries, and Embedded Content** 섹션에서 `+` 클릭
5. **Add Other... → Add Package Dependency...**
6. **Add Local...** 선택 → `MistakeNote/` 폴더 선택
7. **MistakeNote** 라이브러리를 QRIZ 타겟에 추가

**Step 2: 빌드 확인 (아직 기존 파일 있음)**

```bash
xcodebuild -project QRIZ.xcodeproj -scheme QRIZ -configuration Debug build 2>&1 | tail -5
```

Expected: Build Succeeded (아직 App 타겟 파일도 있으므로 중복 오류 가능 — 다음 Task에서 제거)

---

### Task 9: App 타겟에서 기존 파일 제거 및 import 추가

**Files:**
- Delete: `QRIZ/Feature/MistakeNote/` (전체 폴더, Xcode에서 제거)
- Modify: `QRIZ/Feature/TabBar/TabBarCoordinator.swift`

**Step 1: Xcode에서 기존 MistakeNote 파일 제거**

1. Xcode Project Navigator에서 `QRIZ/Feature/MistakeNote` 폴더 선택
2. Delete → **Move to Trash**

**Step 2: TabBarCoordinator에 import 추가**

`QRIZ/Feature/TabBar/TabBarCoordinator.swift` 상단 import 목록에 추가:
```swift
import MistakeNote
```

**Step 3: 빌드 확인**

```bash
xcodebuild -project QRIZ.xcodeproj -scheme QRIZ -configuration Debug build 2>&1 | grep -E "error:|Build succeeded"
```

Expected: `Build succeeded`

**Step 4: Commit**

```bash
git add QRIZ/Feature/TabBar/TabBarCoordinator.swift
git commit -m "refactor: 앱 타겟에서 MistakeNote 모듈 참조로 교체"
```

---

### Task 10: 최종 빌드 및 동작 확인

**Step 1: 클린 빌드**

```bash
xcodebuild clean -project QRIZ.xcodeproj -scheme QRIZ
xcodebuild -project QRIZ.xcodeproj -scheme QRIZ -configuration Debug build 2>&1 | tail -10
```

Expected: `Build succeeded`

**Step 2: 시뮬레이터에서 오답노트 탭 직접 확인 (수동)**

- 오답노트 탭 진입
- 데일리/모의고사 탭 전환
- 문제 카드 탭 → 문제 상세 진입
- 개념 탭 이동 버튼 동작

**Step 3: Commit**

```bash
git add .
git commit -m "refactor: MistakeNote SPM 모듈화 완료"
```
