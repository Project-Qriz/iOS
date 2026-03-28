# DailyLearn 리팩토링 설계

**날짜:** 2026-03-27
**브랜치:** feat/daily-module
**대상:** `Features/Daily/Sources/Daily/DailyLearn/`

---

## 목표

`DailyLearnViewController`에 집중된 레이아웃·UI 책임을 `DailyLearnView`로 분리하여 ViewController를 슬림화한다.
불필요한 파일을 삭제하고 기존 버그 5건을 수정한다.
테스트는 코드 리뷰 이후 별도 작업으로 진행한다.

---

## 파일 구조

### 변경 후

```
DailyLearn/
├── View/
│   ├── DailyLearnView.swift          ← 신규
│   └── StudyContentCell.swift
├── ViewController/
│   └── DailyLearnViewController.swift  ← 슬림화
└── ViewModel/
    └── DailyLearnViewModel.swift
```

### 삭제

| 파일 | 이유 |
|---|---|
| `DailyLearnSectionTitleLabel.swift` | 단순 UILabel 서브클래스 — `DailyLearnView` 내 private 프로퍼티로 인라인 처리 |
| `StudyContentView.swift` | 미사용 파일 |

---

## DailyLearnView

모든 레이아웃 프로퍼티와 UI 구성을 담당한다. ViewController는 `loadView()`에서 이 뷰를 rootView로 설정한다.

```swift
final class DailyLearnView: UIView {

    // ViewController가 CollectionView datasource/delegate 연결에 사용
    let studyCollectionView: UICollectionView

    // ViewModel Output에 따라 ViewController가 호출
    // 내부에서 setTitleLabels / setTestSubtextLabel / setNavigatorButton /
    // setNavigatorButtonHeight 역할을 모두 수행한다
    // setNavigatorButtonHeight는 기존 testNavigatorHeightConstraint 패턴(stored constraint)을 유지한다
    func configure(state: DailyTestState, type: DailyLearnType, score: Double?)

    // ViewController가 conceptArr를 업데이트한 직후 호출
    // 내부 동작: reloadData() → layoutIfNeeded() → stored heightAnchor constraint 재설정
    // (기존 updateCollectionViewHeight() 역할을 대체하는 메서드)
    func reloadConcepts()

    // testNavigator 탭 핸들러 (init에서 UITapGestureRecognizer 1회 등록)
    var onTestNavigatorTap: (() -> Void)?
}
```

`DailyLearnSectionTitleLabel` 역할은 `DailyLearnView` 내 private `UILabel` 프로퍼티 두 개로 흡수한다.

**init에서 처리할 항목:**
- `studyCollectionView`에 `StudyContentCell` 셀 등록 (`register(_:forCellWithReuseIdentifier:)`)
- `testNavigator`에 `UITapGestureRecognizer` 1회 등록

기존 코드는 `setNavigatorButton()`이 호출될 때마다 gestureRecognizer를 중복 추가하는 버그가 있었다. `init`에서 1회만 등록하고 `onTestNavigatorTap` 클로저를 호출하는 방식으로 교체한다.

**`reloadConcepts()` 구현 주의사항:**
`layoutIfNeeded()` 호출이 필수다. 이 호출 없이는 `contentSize.height`가 stale 상태이므로 높이 constraint가 잘못 계산된다.
```swift
func reloadConcepts() {
    studyCollectionView.reloadData()
    studyCollectionView.layoutIfNeeded()
    // stored heightAnchor constraint 재설정
}
```

---

## DailyLearnViewController (변경 후 책임)

- `loadView()`: rootView를 `DailyLearnView`로 설정
- `bind()`: ViewModel Output → `DailyLearnView` 메서드 호출
- CollectionView `UICollectionViewDataSource` / `UICollectionViewDelegateFlowLayout`
- `conceptArr: [(Int, String)]` 소유 (CollectionView 데이터소스로서)
- 네비게이션 바 설정 (`setNavigationItems()`)

레이아웃, 높이 계산, 상태별 UI 텍스트 설정 로직은 모두 `DailyLearnView`로 이동한다.

**CollectionView 연결:**
`loadView()` 또는 `viewDidLoad()` 초기화 시점에 ViewController 자신을 `studyCollectionView`의 `dataSource`와 `delegate`로 할당한다.
`StudyContentCell` 등록은 `DailyLearnView.init`에서 처리하므로 ViewController에서 별도 등록이 불필요하다.

---

## DailyNavigating 프로토콜 변경

**파일 위치: `DailyCoordinator.swift`** — public `DailyCoordinator`와 internal `DailyNavigating`이 함께 선언된 파일.

기존 `quitDaily()`는 DailyTest·DailyResult 화면에서 DailyLearn으로 돌아오는 **내부 네비게이션** 메서드다. Daily 세션 전체를 종료하는 용도와 구분된다.

`DailyNavigating`에 `finishDaily()`를 추가한다. `public DailyCoordinator`에는 추가하지 않는다.

```swift
// DailyCoordinator.swift 내 DailyNavigating (internal)
@MainActor
protocol DailyNavigating: DailyCoordinator {
    func showDailyLearn()
    func showConcept(chapter: Chapter, conceptItem: ConceptItem)
    func showDailyTest()
    func showDailyResult()
    func showResultDetail(resultDetailData: ResultDetailData)
    func showProblemExplanation(questionId: Int)
    func quitDaily()       // 기존 유지 — DailyTest/DailyResult → DailyLearn 복귀
    func finishDaily()     // 추가 — DailyLearn 뒤로가기 → Daily 세션 전체 종료
}
```

### DailyCoordinatorImpl 구현

```swift
func finishDaily() {
    delegate?.didQuitDaily(self)
}
```

### DailyLearnViewController 변경

Coordinator는 `tabBarController` 참조가 없으므로 탭 바 복원은 ViewController에서 담당한다.

```swift
// Before
case .moveToHome:
    tabBarController?.tabBar.isHidden = false
    if let coordinator = coordinator {
        coordinator.delegate?.didQuitDaily(coordinator)
    }

// After
case .moveToHome:
    tabBarController?.tabBar.isHidden = false
    coordinator?.finishDaily()
```

---

## 버그 수정

| # | 위치 | 문제 | 수정 |
|---|---|---|---|
| 1 | `DailyLearnView.addViews()` | `testSubtextLabel` trailing `constant: 18` (양수 — 화면 밖으로 나감) | `constant: -18` |
| 2 | `DailyLearnView.addViews()` | `relatedTestTitleLabel` trailing anchor가 `scrollView` 참조 (내용 영역이 아닌 스크롤 뷰 기준) | `scrollInnerView.trailingAnchor`로 변경 |
| 3 | `DailyLearnView.reloadConcepts()` | `heightAnchor` constraint 매번 새로 추가해 conflict 누적 (기존 `updateCollectionViewHeight()`) | stored constraint 패턴으로 교체 |
| 4 | `DailyLearnView.init` | `testNavigator`에 gestureRecognizer를 `setNavigatorButton()` 호출마다 중복 추가 | `init`에서 1회만 등록, `onTestNavigatorTap` 클로저로 교체 |
| 5 | `DailyLearnViewController.bind()` | VC가 `coordinator?.delegate?.didQuitDaily(coordinator)` 직접 호출 (coordinator 내부 노출) | `coordinator?.finishDaily()`로 교체 |

---

## 작업 순서

1. `DailyLearnSectionTitleLabel.swift`, `StudyContentView.swift` 삭제
2. `DailyLearnView.swift` 작성 (레이아웃 이전 + 버그 1·2·3·4 수정 포함)
3. `DailyLearnViewController` 슬림화 (`loadView()` 적용, `DailyLearnView` API 호출로 교체, 버그 5 수정)
4. `DailyCoordinator.swift`의 `DailyNavigating`에 `finishDaily()` 추가, `DailyCoordinatorImpl` 구현
5. 빌드 확인

---

## 참고

- 기존 설계: `docs/superpowers/specs/2026-03-27-daily-modularization-design.md`
- Coordinator 패턴: `Features/Daily/Sources/Daily/Coordinator/`
