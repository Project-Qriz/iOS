# MistakeNote SwiftUI-first 리팩토링 구현 플랜

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** MistakeNote 모듈의 UIKit 스타일 Input/Output Combine 패턴을 SwiftUI-first 패턴으로 전환해 구조적 버그 및 불필요한 보일러플레이트 제거

**Architecture:** ViewModel의 Input enum + transform 메서드를 직접 호출 메서드로 대체. Navigation output은 `onNavigate` closure로 전달. SwiftUI View는 ViewModel 메서드를 직접 호출하고 ViewController는 onNavigate만 구독.

**Tech Stack:** Swift 6, SwiftUI, Combine(최소화), UIHostingController, SPM

---

### Task 1: MistakeNoteListViewModel — 메서드화

**Files:**
- Modify: `MistakeNote/Sources/MistakeNote/MistakeNoteList/ViewModel/MistakeNoteListViewModel.swift`

**배경:**
현재 `Input` enum과 `transform(input:)` 메서드로 모든 액션을 처리. `MistakeNoteViewController`와 `MistakeNoteMainView` 두 곳에서 `transform`을 호출하면 구독이 2개 생기는 버그가 있음.

**Step 1: Input enum 제거 및 onNavigate closure 추가**

`public enum Input { ... }` 블록 전체 제거.
`public func transform(...)` 메서드 전체 제거.
`cancellables` 제거.

아래를 추가:
```swift
// Output은 그대로 유지
// private let output = PassthroughSubject<Output, Never>() 제거하고 아래로 교체:
public var onNavigate: ((Output) -> Void)?
```

**Step 2: 개별 액션 메서드 추가**

`// MARK: - Methods` 섹션에 아래 메서드들 추가:

```swift
public func viewDidLoad() async {
    await loadDailyInitialData()
}

public func tabSelected(_ tab: MistakeNoteTab) {
    selectedTab = tab
    resetAllFilters()
    Task { await handleTabChange(tab) }
}

public func daySelected(_ day: String) {
    selectedDay = day
    resetAllFilters()
    Task { await loadClips(category: 2, testInfo: extractTestInfo(from: day)) }
}

public func sessionSelected(_ session: String) {
    selectedSession = session
    resetAllFilters()
    Task { await loadClips(category: 3, testInfo: extractSessionInfo(from: session)) }
}

public func questionTapped(_ question: MistakeNoteQuestion) {
    onNavigate?(.navigateToClipDetail(clipId: question.id))
}

public func goToExamTapped() {
    onNavigate?(.navigateToExam(tab: selectedTab))
}

public func filterAllChanged(_ filter: QuestionFilter) {
    filterAll = filter
}

public func conceptFilterApplied(_ concepts: Set<String>, _ subject: QRIZUtils.Subject?) {
    selectedConceptsFilter = concepts
    selectedFilterSubject = subject
}
```

`resetConceptFilters()`는 이미 private이므로 public으로 변경:
```swift
public func resetConceptFilters() {
    selectedConceptsFilter = []
    selectedFilterSubject = nil
}
```

**Step 3: 불필요한 import 제거 확인**
- `import Combine` 제거 (PassthroughSubject 없어지므로)
- `private var cancellables` 제거

**Step 4: 빌드 확인**
```bash
xcodebuild -project QRIZ.xcodeproj -scheme QRIZ -configuration Debug build 2>&1 | grep -E "error:|Build succeeded"
```
Expected: 관련 파일들에서 컴파일 에러 발생 (MistakeNoteMainView, MistakeNoteViewController 아직 미수정)

---

### Task 2: MistakeNoteMainView — Combine 배관 제거

**Files:**
- Modify: `MistakeNote/Sources/MistakeNote/MistakeNoteList/View/MistakeNoteMainView.swift`

**배경:**
`input: PassthroughSubject`, `hasAppeared`, `bindViewModel()` 이 세 가지는 오직 transform을 한 번만 호출하기 위한 보일러플레이트. 제거하고 ViewModel 메서드 직접 호출로 전환.

**Step 1: 프로퍼티 정리**

제거:
```swift
private let input = PassthroughSubject<MistakeNoteListViewModel.Input, Never>()
@State private var hasAppeared: Bool = false
```

**Step 2: body 수정**

`.onAppear` 블록 제거하고 `.task` 추가:
```swift
// 제거
.onAppear {
    guard !hasAppeared else { return }
    hasAppeared = true
    bindViewModel()
    input.send(.viewDidLoad)
}

// 추가
.task {
    await viewModel.viewDidLoad()
}
```

`onChange` 수정:
```swift
// 기존
.onChange(of: viewModel.selectedTab) { _, newTab in
    input.send(.tabSelected(newTab))
}

// 변경 후
.onChange(of: viewModel.selectedTab) { _, newTab in
    viewModel.tabSelected(newTab)
}
```

**Step 3: 각 액션 호출 수정**

`contentSection`:
```swift
MistakeNoteNoRecordView(
    onGoToExam: {
        viewModel.goToExamTapped()
    }
)
```

`questionSection` (MistakeNoteFilterBarView):
```swift
MistakeNoteFilterBarView(
    filterAll: viewModel.filterAll,
    hasActiveConceptFilter: !viewModel.selectedConceptsFilter.isEmpty,
    hasFilterForSubject: { viewModel.hasFilterForSubject($0) },
    onFilterAllChanged: { viewModel.filterAllChanged($0) },
    onSubjectTapped: { subject in
        sheetSubject = subject
        showSubjectFilterSheet = true
    },
    onReset: { viewModel.resetConceptFilters() }
)
```

`questionListOrEmptyView`:
```swift
MistakeNoteQuestionListView(
    questions: viewModel.displayedQuestions,
    onQuestionTap: { question in
        viewModel.questionTapped(question)
    }
)
```

**Step 4: handleDropdownSelection 수정**
```swift
func handleDropdownSelection(_ item: String) {
    switch viewModel.selectedTab {
    case .daily:
        viewModel.daySelected(item)
    case .mockExam:
        viewModel.sessionSelected(item)
    }
}
```

**Step 5: subjectFilterSheet onApply 버그 수정**

기존 코드의 `viewModel.selectedFilterSubject`를 `sheetSubject`로 수정:
```swift
onApply: { selectedConcepts in
    viewModel.conceptFilterApplied(selectedConcepts, sheetSubject)
}
```

**Step 6: bindViewModel 제거**

`private func bindViewModel()` 메서드 전체 제거.
`import Combine` 제거.

**Step 7: 빌드 확인**
```bash
xcodebuild -project QRIZ.xcodeproj -scheme QRIZ -configuration Debug build 2>&1 | grep -E "error:|Build succeeded"
```

---

### Task 3: MistakeNoteViewController — transform 제거

**Files:**
- Modify: `MistakeNote/Sources/MistakeNote/MistakeNoteList/ViewController/MistakeNoteViewController.swift`

**배경:**
`bind()`에서 빈 input으로 `viewModel.transform` 호출하던 것을 `viewModel.onNavigate` closure로 교체.

**Step 1: 프로퍼티 제거**
```swift
// 제거
private let input = PassthroughSubject<MistakeNoteListViewModel.Input, Never>()
private var cancellables = Set<AnyCancellable>()
```

**Step 2: bind() 수정**
```swift
private func bind() {
    viewModel.onNavigate = { [weak self] output in
        guard let self else { return }
        switch output {
        case .navigateToClipDetail(let clipId):
            self.delegate?.mistakeNoteViewController(self, didSelectClipWithId: clipId)
        case .navigateToExam(let tab):
            self.delegate?.mistakeNoteViewController(self, didRequestExamForTab: tab)
        }
    }
}
```

**Step 3: import Combine 제거**

**Step 4: 빌드 확인**
```bash
xcodebuild -project QRIZ.xcodeproj -scheme QRIZ -configuration Debug build 2>&1 | grep -E "error:|Build succeeded"
```
Expected: Build succeeded

---

### Task 4: ProblemDetailViewModel — 메서드화

**Files:**
- Modify: `MistakeNote/Sources/MistakeNote/ProblemExplanation/ViewModel/ProblemDetailViewModel.swift`

**배경:**
MistakeNoteListViewModel과 동일한 패턴. Input enum + transform 제거, 개별 메서드로 전환.

**Step 1: Input enum 제거**

`public enum Input { ... }` 전체 제거.

**Step 2: transform 제거 및 onNavigate 추가**

`public func transform(...)` 전체 제거.
`cancellables` 제거.
`private let output: PassthroughSubject<Output, Never>` 제거.

추가:
```swift
public var onNavigate: ((Output) -> Void)?
```

**Step 3: 개별 메서드 추가**

```swift
public func viewDidLoad() {
    Task { await fetchProblemDetail() }
}

public func retry() {
    Task { await fetchProblemDetail() }
}

public func learnButtonTapped() {
    onNavigate?(.navigateToConceptTab)
}

public func conceptTapped(concept: String) {
    if let (chapter, conceptItem) = findConceptItem(for: concept) {
        onNavigate?(.navigateToConceptDetail(chapter: chapter, conceptItem: conceptItem))
    }
}
```

**Step 4: import Combine 제거**

**Step 5: 빌드 확인**
```bash
xcodebuild -project QRIZ.xcodeproj -scheme QRIZ -configuration Debug build 2>&1 | grep -E "error:|Build succeeded"
```
Expected: ProblemDetailView, ProblemDetailViewController 에러 발생 (아직 미수정)

---

### Task 5: ProblemDetailView — PassthroughSubject 제거

**Files:**
- Modify: `MistakeNote/Sources/MistakeNote/ProblemExplanation/View/ProblemDetailView.swift`

**배경:**
3개의 PassthroughSubject를 외부에서 파라미터로 받는 구조를 closure로 교체.

**Step 1: 프로퍼티 변경**

```swift
// 제거
public let retryInput: PassthroughSubject<Void, Never>
public let learnButtonTapInput: PassthroughSubject<Void, Never>
public let conceptTapInput: PassthroughSubject<String, Never>

// 추가
public let onRetry: () -> Void
public let onLearnButtonTapped: () -> Void
public let onConceptTapped: (String) -> Void
```

**Step 2: init 변경**
```swift
public init(
    viewModel: ProblemDetailViewModel,
    onRetry: @escaping () -> Void,
    onLearnButtonTapped: @escaping () -> Void,
    onConceptTapped: @escaping (String) -> Void
) {
    self.viewModel = viewModel
    self.onRetry = onRetry
    self.onLearnButtonTapped = onLearnButtonTapped
    self.onConceptTapped = onConceptTapped
}
```

**Step 3: 호출부 수정**

`errorView`:
```swift
Button("다시 시도") {
    onRetry()
}
```

`learnButton`:
```swift
Button(action: { onLearnButtonTapped() }) { ... }
```

`ProblemKeyConceptsView`에 `onConceptTap` 전달 방식 확인 후 수정.
현재: `onConceptTap: conceptTapInput`
변경 후: ProblemKeyConceptsView의 파라미터 타입 확인 필요.

**Step 4: import Combine 제거 가능 여부 확인 후 제거**

**Step 5: Preview 수정**
```swift
#Preview {
    NavigationView {
        ProblemDetailView(
            viewModel: ProblemDetailViewModel { ... },
            onRetry: {},
            onLearnButtonTapped: {},
            onConceptTapped: { _ in }
        )
    }
}
```

**Step 6: 빌드 확인**
```bash
xcodebuild -project QRIZ.xcodeproj -scheme QRIZ -configuration Debug build 2>&1 | grep -E "error:|Build succeeded"
```

---

### Task 6: ProblemDetailViewController — PassthroughSubject 정리

**Files:**
- Modify: `MistakeNote/Sources/MistakeNote/ProblemExplanation/ViewController/ProblemDetailViewController.swift`

**배경:**
4개의 PassthroughSubject 제거, viewModel.onNavigate 구독, ProblemDetailView에 closure 전달.

**Step 1: PassthroughSubject 프로퍼티 제거**
```swift
// 제거
private let input: PassthroughSubject<ProblemDetailViewModel.Input, Never> = .init()
private let retryInput: PassthroughSubject<Void, Never> = .init()
private let learnButtonTapInput: PassthroughSubject<Void, Never> = .init()
private let conceptTapInput: PassthroughSubject<String, Never> = .init()
private var cancellables = Set<AnyCancellable>()
```

**Step 2: init 수정**

ProblemDetailView 생성 시 closure 전달:
```swift
public init(viewModel: ProblemDetailViewModel) {
    self.viewModel = viewModel
    let swiftUIView = ProblemDetailView(
        viewModel: viewModel,
        onRetry: { viewModel.retry() },
        onLearnButtonTapped: { viewModel.learnButtonTapped() },
        onConceptTapped: { viewModel.conceptTapped(concept: $0) }
    )
    super.init(rootView: swiftUIView)
    self.hidesBottomBarWhenPushed = true
}
```

**Step 3: viewDidLoad 수정**
```swift
override public func viewDidLoad() {
    super.viewDidLoad()
    configureNavigationTitle()
    bind()
    viewModel.viewDidLoad()
}
```

**Step 4: bind() 수정**
```swift
private func bind() {
    viewModel.onNavigate = { [weak self] output in
        guard let self else { return }
        switch output {
        case .navigateToConceptTab:
            self.coordinator?.navigateToConceptTab()
        case .navigateToConceptDetail(let chapter, let conceptItem):
            self.coordinator?.navigateToConcept(chapter: chapter, conceptItem: conceptItem)
        }
    }
}
```

**Step 5: import Combine 제거**

**Step 6: 빌드 확인**
```bash
xcodebuild -project QRIZ.xcodeproj -scheme QRIZ -configuration Debug build 2>&1 | grep -E "error:|Build succeeded"
```
Expected: Build succeeded

---

### Task 7: 기타 수정

**Files:**
- Modify: `MistakeNote/Sources/MistakeNote/MistakeNoteList/ViewModel/SubjectFilterSheetViewModel.swift`
- Modify: `MistakeNote/Sources/MistakeNote/MistakeNoteList/View/SubjectFilterSheet/FilterSectionView.swift`
- Create: `MistakeNote/Sources/MistakeNote/Extensions/FlowLayout.swift`
- Modify: `MistakeNote/Sources/MistakeNote/MistakeNoteList/View/DaySelectDropdownButton.swift`

**Step 1: SubjectFilterSheetViewModel @MainActor 추가**

```swift
// 기존
public final class SubjectFilterSheetViewModel: ObservableObject {

// 변경 후
@MainActor
public final class SubjectFilterSheetViewModel: ObservableObject {
```

**Step 2: FlowLayout 분리**

`FilterSectionView.swift`에서 `// MARK: - Flow Layout` 부터 파일 끝 `FlowLayout` 구조체 전체를 잘라내서
`MistakeNote/Sources/MistakeNote/Extensions/FlowLayout.swift` 파일 생성 후 붙여넣기:

```swift
//
//  FlowLayout.swift
//  MistakeNote
//

import SwiftUI

public struct FlowLayout: Layout {
    // (기존 코드 그대로)
}
```

**Step 3: DaySelectDropdownList title 파라미터 추가**

```swift
public struct DaySelectDropdownList: View {
    public let days: [String]
    public let title: String          // 추가
    @Binding public var selectedDay: String
    @Binding public var isExpanded: Bool
    public var onDaySelected: ((String) -> Void)?

    public init(days: [String], title: String = "회차 선택", selectedDay: Binding<String>, isExpanded: Binding<Bool>, onDaySelected: ((String) -> Void)? = nil) {
        self.days = days
        self.title = title
        _selectedDay = selectedDay
        _isExpanded = isExpanded
        self.onDaySelected = onDaySelected
    }
```

body의 `Text("회차 선택")` → `Text(title)` 수정.

`MistakeNoteMainView`의 `dropdownOverlay`에서 호출부 수정:
```swift
DaySelectDropdownList(
    days: viewModel.dropdownItems,
    title: viewModel.selectedTab == .daily ? "날짜 선택" : "회차 선택",
    selectedDay: selectedItemBinding,
    isExpanded: $isDropdownExpanded,
    onDaySelected: { item in
        handleDropdownSelection(item)
    }
)
```

**Step 4: 빌드 확인**
```bash
xcodebuild -project QRIZ.xcodeproj -scheme QRIZ -configuration Debug build 2>&1 | grep -E "error:|Build succeeded"
```
Expected: Build succeeded
