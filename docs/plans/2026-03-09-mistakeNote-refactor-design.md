# MistakeNote 내부 리팩토링 설계

## 배경

MistakeNote SPM 모듈화 완료 후 내부 코드 품질 개선 작업.
중복 코드 제거, 에러 처리 개선, 뷰 컴포넌트 분리가 목표.

## 작업 범위

### 1. ViewModel 정리 (MistakeNoteListViewModel)

**중복 로딩 로직 통합**
- `loadDailyQuestions(for:)`와 `loadMockExamQuestions(for:)` → `loadClips(category:testInfo:)`로 통합
- category 파라미터(2=데일리, 3=모의고사)만 다르고 나머지 로직 동일

**normalizeConceptName 중복 제거**
- `MistakeNoteListViewModel`, `SubjectFilterSheetViewModel`, `FilterSectionView` 3곳에 동일한 구현 존재
- `String` extension으로 추출해 `MistakeNote` 패키지 내 공유

**Magic String → Enum 전환**
- `"모두"`, `"오답만"` → `QuestionFilter` enum

### 2. 에러 처리 개선

- `print()` → `Logger.make(category:)` 로 교체
- Account, Conceptbook 모듈과 동일한 패턴 적용

### 3. 뷰 분해 (MistakeNoteMainView)

- `filterChipsRow` + `resetFilterButton` + `subjectFilterButton` → `MistakeNoteFilterBarView` 신규 파일로 추출
- `MistakeNoteMainView`는 `MistakeNoteFilterBarView`를 조합해 사용

**MistakeNoteFilterBarView 인터페이스**
```swift
public struct MistakeNoteFilterBarView: View {
    let filterAll: String            // "모두" / "오답만"
    let hasActiveConceptFilter: Bool
    let hasFilterForSubject: (Subject) -> Bool
    var onFilterAllChanged: (String) -> Void
    var onSubjectTapped: (Subject) -> Void
    var onReset: () -> Void
}
```

## 변경 파일 목록

- `MistakeNote/Sources/MistakeNote/MistakeNoteList/ViewModel/MistakeNoteListViewModel.swift`
- `MistakeNote/Sources/MistakeNote/MistakeNoteList/ViewModel/SubjectFilterSheetViewModel.swift`
- `MistakeNote/Sources/MistakeNote/MistakeNoteList/View/MistakeNoteMainView.swift`
- `MistakeNote/Sources/MistakeNote/MistakeNoteList/View/FilterSectionView.swift`
- 신규: `MistakeNote/Sources/MistakeNote/MistakeNoteList/View/MistakeNoteFilterBarView.swift`
