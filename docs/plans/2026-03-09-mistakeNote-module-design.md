# MistakeNote SPM 모듈화 설계

## 배경

현재 MistakeNote 피처(MistakeNoteList, ProblemExplanation)는 App 타겟에 위치한다.
Account, Conceptbook과 동일하게 SPM 로컬 패키지로 분리해 관심사 분리와 빌드 단위 명확화를 목표로 한다.

## 접근 방법

MistakeNoteList + ProblemExplanation을 하나의 `MistakeNote` 패키지로 분리한다.
현재 외부 재사용이 없으므로 두 패키지로 쪼개지 않는다(YAGNI).
테스트 타겟은 이번 PR에서 제외하고 소스 타겟만 구성한다.

## 패키지 구조

```
MistakeNote/
├── Package.swift
└── Sources/
    └── MistakeNote/
        ├── Coordinator/
        │   └── MistakeNoteCoordinator.swift
        ├── MistakeNoteList/
        │   ├── View/
        │   │   ├── DaySelectDropdownButton.swift
        │   │   ├── FilterChipButton.swift
        │   │   ├── MistakeNoteEmptyView.swift
        │   │   ├── MistakeNoteMainView.swift
        │   │   ├── MistakeNoteNoRecordView.swift
        │   │   ├── MistakeNoteQuestionCard.swift
        │   │   ├── MistakeNoteQuestionListView.swift
        │   │   ├── MistakeNoteTabSelector.swift
        │   │   └── SubjectFilterSheet/
        │   │       ├── FilterChip.swift
        │   │       ├── FilterSectionView.swift
        │   │       └── SubjectFilterSheet.swift
        │   └── ViewModel/
        │       ├── MistakeNoteListViewModel.swift
        │       └── SubjectFilterSheetViewModel.swift
        └── ProblemExplanation/
            ├── View/
            │   ├── ProblemDetailView.swift
            │   ├── ProblemHeaderCardView.swift
            │   ├── ProblemKeyConceptsView.swift
            │   ├── ProblemOptionView.swift
            │   ├── ProblemQuestionSectionView.swift
            │   ├── ProblemResultView.swift
            │   └── ProblemSolutionView.swift
            └── ViewModel/
                └── ProblemDetailViewModel.swift
```

## Package.swift

- swift-tools-version: 6.0
- 최소 배포 타겟: iOS 17.0
- 의존 패키지: `Network`, `DesignSystem`, `QRIZUtils`, `Conceptbook`
- 테스트 타겟 없음

## App 타겟 변경 사항

- `QRIZ/Feature/MistakeNote/` 전체 제거
- `TabBarCoordinator`에 `import MistakeNote` 추가
- `QRIZ.xcodeproj`에 MistakeNote 로컬 패키지 링크 추가
