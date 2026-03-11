# MistakeNote 테스트 설계

**Date:** 2026-03-11
**Scope:** MistakeNote 모듈 유닛 테스트 + 스냅샷 테스트 추가

## 배경

Account 모듈과 동일한 테스트 패턴을 MistakeNote 모듈에 적용한다.
MistakeNote ViewModel은 Combine Input/Output 패턴이 아닌 `@Published ObservableObject` 패턴을 사용하므로, 유닛 테스트는 `@Published` 프로퍼티를 직접 읽는 방식으로 작성한다.

## Package.swift 변경

```swift
dependencies: [
    .package(path: "../Network"),
    .package(path: "../DesignSystem"),
    .package(path: "../QRIZUtils"),
    .package(path: "../Conceptbook"),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.18.9"),
],
targets: [
    .target(name: "MistakeNote", ...),
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
```

## 파일 구조

```
MistakeNote/Tests/MistakeNoteTests/
├── Mocks/
│   ├── MockMistakeNoteService.swift      # 유닛 테스트용 (configurable)
│   └── SnapshotServiceStubs.swift        # 스냅샷 테스트용 (fatalError stub)
├── UnitTests/
│   ├── MistakeNoteListViewModelTests.swift
│   ├── ProblemDetailViewModelTests.swift
│   └── SubjectFilterSheetViewModelTests.swift
├── SnapshotTests/
│   ├── MistakeNoteSnapshotTests.swift
│   ├── ProblemDetailSnapshotTests.swift
│   └── SubjectFilterSheetSnapshotTests.swift
├── SnapshotTestHelpers.swift
└── TestHelpers.swift
```

## 유닛 테스트 커버리지

### MistakeNoteListViewModelTests

| 테스트 | 검증 내용 |
|--------|-----------|
| `displayedQuestions_noFilter_returnsAll` | 필터 없음 → 전체 반환 |
| `displayedQuestions_incorrectOnly_excludesCorrect` | `.incorrectOnly` → 오답만 반환 |
| `displayedQuestions_conceptFilter_returnsMatchingOnly` | conceptFilter → 해당 concept만 반환 |
| `tabSelected_resetsAllFilters` | 탭 변경 → 필터 전체 리셋 |
| `daySelected_resetsAllFilters` | 날짜 선택 → 필터 리셋 |
| `sessionSelected_resetsAllFilters` | 회차 선택 → 필터 리셋 |
| `hasFilterForSubject_true_whenSubjectConceptSelected` | 해당 subject concept 있을 때 true |
| `hasFilterForSubject_false_whenNoConceptSelected` | 없을 때 false |
| `questionTapped_triggersNavigateToClipDetail` | `onNavigate(.navigateToClipDetail)` |
| `goToExamTapped_triggersNavigateToExam` | `onNavigate(.navigateToExam)` |
| `viewDidLoad_setsAvailableDays` | mock service 호출 후 `availableDays` 설정 (async) |

### ProblemDetailViewModelTests

| 테스트 | 검증 내용 |
|--------|-----------|
| `learnButtonTapped_triggersNavigateToConceptTab` | `onNavigate(.navigateToConceptTab)` |
| `conceptTapped_existingConcept_triggersNavigateToConceptDetail` | 존재하는 concept → `.navigateToConceptDetail` |
| `conceptTapped_unknownConcept_doesNotTriggerNavigate` | 존재하지 않는 concept → `onNavigate` 미호출 |
| `viewDidLoad_setsProblemDetail` | fetch 성공 후 `problemDetail` 설정 (async) |
| `retry_afterFailure_succeeds` | 실패 후 `retry()` 호출 → 성공 |

### SubjectFilterSheetViewModelTests

| 테스트 | 검증 내용 |
|--------|-----------|
| `hasSelections_false_whenEmpty` | selectedConcepts 비어있을 때 false |
| `hasSelections_true_whenNotEmpty` | selectedConcepts 있을 때 true |
| `hasChanges_false_whenSameAsInitial` | initial과 동일 → false |
| `hasChanges_true_whenDifferentFromInitial` | 다를 때 → true |
| `reset_clearsSelectedConcepts` | `reset()` → `selectedConcepts` 비워짐 |
| `availableChapters_onlyIncludesChaptersWithAvailableConcepts` | `availableConcepts`에 포함된 chapter만 반환 |

## 스냅샷 테스트

### SnapshotTestHelpers.swift

```swift
@MainActor
class MistakeNoteSnapshotTestCase: XCTestCase {
    static let deviceSize = CGSize(width: 393, height: 852) // iPhone 16 Pro
}
```

### 스냅샷 대상

| 파일 | 상태 | 비고 |
|------|------|------|
| `MistakeNoteSnapshotTests` | 초기 빈 상태 | `.task` 비동기 미실행 → 빈 화면 |
| `ProblemDetailSnapshotTests` | 로딩 상태 | `Task` 비동기 미실행 → spinner |
| `SubjectFilterSheetSnapshotTests` | 초기 상태 / concept 선택된 상태 | UIHostingController로 wrap |

## 결정사항

- 유닛 테스트: Swift Testing (`@Suite`, `@Test`, `#expect`)
- `@Published` 프로퍼티는 메서드 호출 후 직접 읽기 (collect() 헬퍼 불필요)
- async 테스트: `await` 직접 사용
- 스냅샷 디바이스: iPhone 16 Pro 고정 (`393 × 852`)
- 스냅샷 대상: `of: vc` (ViewController 전체) 통일
