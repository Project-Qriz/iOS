# MistakeNote SwiftUI-first 리팩토링 설계

## 배경

MistakeNote 모듈화 완료 후 아키텍처 품질 개선 작업.
UIKit 기반 Input/Output Combine 패턴을 SwiftUI에서 사용하면서 생긴 이중 구독, 불필요한 PassthroughSubject 등 구조적 문제를 해결한다.

## 문제점

1. `transform` 이중 호출 — `MistakeNoteViewController`와 `MistakeNoteMainView` 둘 다 호출해서 구독 2개 생성
2. `ProblemDetailViewController`가 3개의 `PassthroughSubject`를 SwiftUI View에 파라미터로 전달
3. `SubjectFilterSheetViewModel`에 `@MainActor` 누락
4. `FlowLayout`이 `FilterSectionView.swift`에 혼재
5. `DaySelectDropdownList` 헤더가 "회차 선택"으로 하드코딩
6. `subjectFilterSheet onApply`에서 `viewModel.selectedFilterSubject` 대신 `sheetSubject`를 전달해야 함

## 설계

### 1. ViewModel 액션 메서드화

`Input` enum + `transform` 제거하고 직접 메서드로 전환.
Navigation output은 `onNavigate: ((Output) -> Void)?` closure로 전달.

**MistakeNoteListViewModel**
```swift
// 제거
enum Input { ... }
func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never>

// 추가
var onNavigate: ((Output) -> Void)?
func viewDidLoad() async
func tabSelected(_ tab: MistakeNoteTab)
func daySelected(_ day: String)
func sessionSelected(_ session: String)
func questionTapped(_ question: MistakeNoteQuestion)
func goToExamTapped()
func filterAllChanged(_ filter: QuestionFilter)
func conceptFilterApplied(_ concepts: Set<String>, _ subject: QRIZUtils.Subject?)
func resetConceptFilters()
```

**ProblemDetailViewModel** — 동일 패턴 적용

### 2. MistakeNoteMainView 단순화

- `input: PassthroughSubject` 제거
- `hasAppeared: Bool` 제거
- `bindViewModel()` 제거
- `.onAppear` → `.task { await viewModel.viewDidLoad() }`
- `input.send(.xxx)` → `viewModel.xxx()` 직접 호출

### 3. MistakeNoteViewController 변경

- `input`, `cancellables` 제거
- `bind()`: transform 대신 `viewModel.onNavigate = { ... }`

### 4. ProblemDetailView 변경

PassthroughSubject 파라미터 → closure:
```swift
// 기존
retryInput: PassthroughSubject<Void, Never>
learnButtonTapInput: PassthroughSubject<Void, Never>
conceptTapInput: PassthroughSubject<String, Never>

// 변경 후
onRetry: @escaping () -> Void
onLearnButtonTapped: @escaping () -> Void
onConceptTapped: @escaping (String) -> Void
```

### 5. ProblemDetailViewController 변경

- 4개 PassthroughSubject 제거
- `viewModel.onNavigate = { ... }`
- ProblemDetailView에 closure 전달

### 6. 기타

- `SubjectFilterSheetViewModel`에 `@MainActor` 추가
- `FlowLayout` → `Extensions/FlowLayout.swift` 분리
- `DaySelectDropdownList` title 파라미터 추가
- `subjectFilterSheet onApply` 버그 수정

## 변경 파일 목록

- `MistakeNote/Sources/MistakeNote/MistakeNoteList/ViewModel/MistakeNoteListViewModel.swift`
- `MistakeNote/Sources/MistakeNote/MistakeNoteList/ViewModel/SubjectFilterSheetViewModel.swift`
- `MistakeNote/Sources/MistakeNote/MistakeNoteList/View/MistakeNoteMainView.swift`
- `MistakeNote/Sources/MistakeNote/MistakeNoteList/View/MistakeNoteFilterBarView.swift` (간접 영향 없음)
- `MistakeNote/Sources/MistakeNote/MistakeNoteList/View/SubjectFilterSheet/FilterSectionView.swift`
- `MistakeNote/Sources/MistakeNote/MistakeNoteList/View/DaySelectDropdownButton.swift`
- `MistakeNote/Sources/MistakeNote/MistakeNoteList/ViewController/MistakeNoteViewController.swift`
- `MistakeNote/Sources/MistakeNote/ProblemExplanation/ViewModel/ProblemDetailViewModel.swift`
- `MistakeNote/Sources/MistakeNote/ProblemExplanation/View/ProblemDetailView.swift`
- `MistakeNote/Sources/MistakeNote/ProblemExplanation/ViewController/ProblemDetailViewController.swift`
- 신규: `MistakeNote/Sources/MistakeNote/Extensions/FlowLayout.swift`
