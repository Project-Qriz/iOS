# Exam 모듈화 및 리팩토링 Design

## Goal

`QRIZ/Feature/Exam/`을 `Features/Exam/` SPM 패키지로 분리하고, ExamList/ExamTest View 분리 및 ExamResult를 SwiftUI-native 구조로 전환한다.

## Architecture

Daily 모듈화 패턴을 그대로 따른다.

- **패키지**: `Features/Exam/`, `ExamCoordinator` public/internal 분리 + factory 함수
- **ExamList**: `ExamListView` 추출 (DailyLearnView 패턴)
- **ExamTest**: `ExamTestView` 추출 (DailyTestView 패턴)
- **ExamResult**: `ExamResultViewModel` → `ObservableObject` + delegate 패턴 전환, `ExamResultHostingController` / `ExamResultViewController` 제거, `UIHostingController<ExamResultView>` 직접 사용 (DailyResult 패턴)

## Tech Stack

Swift 5, UIKit, SwiftUI, Combine, SPM, iOS 17+

---

## 파일 구조

| 파일 | 변경 |
|------|------|
| `Features/Exam/Package.swift` | 신규 |
| `Features/Exam/Sources/Exam/Coordinator/ExamCoordinator.swift` | 신규 — public protocol + factory |
| `Features/Exam/Sources/Exam/Coordinator/ExamCoordinatorImpl.swift` | 이동 + 수정 |
| `Features/Exam/Sources/Exam/ExamList/View/ExamListView.swift` | 신규 분리 |
| `Features/Exam/Sources/Exam/ExamList/View/ExamListCell.swift` | 이동 |
| `Features/Exam/Sources/Exam/ExamList/View/ExamListFilterButton.swift` | 이동 |
| `Features/Exam/Sources/Exam/ExamList/View/ExamListFilterItemsView.swift` | 이동 |
| `Features/Exam/Sources/Exam/ExamList/ViewController/ExamListViewController.swift` | 이동 + 수정 |
| `Features/Exam/Sources/Exam/ExamList/ViewModel/ExamListViewModel.swift` | 이동 |
| `Features/Exam/Sources/Exam/ExamSummary/ViewController/ExamSummaryViewController.swift` | 이동 |
| `Features/Exam/Sources/Exam/ExamSummary/ViewModel/ExamSummaryViewModel.swift` | 이동 |
| `Features/Exam/Sources/Exam/ExamTest/View/ExamTestView.swift` | 신규 분리 |
| `Features/Exam/Sources/Exam/ExamTest/View/ExamTestFooterView.swift` | 이동 |
| `Features/Exam/Sources/Exam/ExamTest/ViewController/ExamTestViewController.swift` | 이동 + 수정 |
| `Features/Exam/Sources/Exam/ExamTest/ViewModel/ExamTestViewModel.swift` | 이동 + 수정 |
| `Features/Exam/Sources/Exam/ExamResult/View/ExamResultView.swift` | 이동 + 수정 |
| `Features/Exam/Sources/Exam/ExamResult/View/ExamResultScoreView.swift` | 이동 |
| `Features/Exam/Sources/Exam/ExamResult/View/ExamScoresGraphView.swift` | 이동 |
| `Features/Exam/Sources/Exam/ExamResult/ViewModel/ExamResultViewModel.swift` | 이동 + 리팩토링 |
| `QRIZ/Feature/Exam/` (전체) | 삭제 |
| `QRIZ/Feature/Home/HomeCoordinator.swift` | `import Exam` + factory 패턴 적용 |
| `QRIZ.xcodeproj/project.pbxproj` | Exam 패키지 링크 추가, 기존 파일 참조 제거 |

---

## Package.swift

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Exam",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Exam", targets: ["Exam"]),
    ],
    dependencies: [
        .package(path: "../../Core/Network"),
        .package(path: "../../Core/DesignSystem"),
        .package(path: "../../Core/QRIZUtils"),
        .package(path: "../ExamKit"),
        .package(path: "../Conceptbook"),
        .package(path: "../MistakeNote"),
    ],
    targets: [
        .target(
            name: "Exam",
            dependencies: [
                "Network",
                "DesignSystem",
                "QRIZUtils",
                "ExamKit",
                "Conceptbook",
                "MistakeNote",
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
    ]
)
```

---

## ExamCoordinator public/internal 분리

DailyCoordinator 패턴과 동일하게 구성한다.

```swift
// ExamCoordinator.swift (public)
import QRIZUtils  // Coordinator 프로토콜

@MainActor
public protocol ExamCoordinator: Coordinator {
    var delegate: ExamCoordinatorDelegate? { get set }
}

@MainActor
public protocol ExamCoordinatorDelegate: AnyObject {
    func didQuitExam(_ coordinator: any ExamCoordinator)
    func moveFromExamToConcept(_ coordinator: any ExamCoordinator)
}

@MainActor
public func makeExamCoordinator(
    navigationController: UINavigationController,
    examService: any ExamService
) -> any ExamCoordinator {
    ExamCoordinatorImpl(navigationController: navigationController, examService: examService)
}
```

내부 네비게이션 메서드는 `internal` 프로토콜로 분리:

```swift
// internal
@MainActor
protocol ExamNavigating: ExamCoordinator {
    func showExamList()
    func showExamSummary(examId: Int)
    func showExamTest(examId: Int)
    func showExamResult(examId: Int)
    func showResultDetail(resultDetailData: ResultDetailData)
    func showProblemExplanation(questionId: Int)
    func quitExam()
}
```

`ExamCoordinatorImpl`은 `internal`, `ExamNavigating` 채택.

---

## ExamList — ExamListView 분리

`ExamListViewController`의 서브뷰 선언, 레이아웃, UI 업데이트 메서드를 `ExamListView`로 추출한다.

```swift
// ExamListView.swift
final class ExamListView: UIView {
    let examListFilterButton = ExamListFilterButton()
    let examListFilterItemsView = ExamListFilterItemsView()
    private(set) var collectionView: UICollectionView!

    func setCollectionViewItem(_ items: [ExamInfo]) { ... }
    func selectFilterItem(_ filterType: ExamListFilterType) { ... }
    func setFilterItemsVisibility(isVisible: Bool) { ... }
}

// ExamListViewController.swift
override func loadView() {
    contentView = ExamListView()
    view = contentView
}
```

`ExamListViewController`는 `bind()` + `handleOutput()` + coordinator 호출만 담당.

---

## ExamTest — ExamTestView 분리

`ExamTestViewController`의 서브뷰(progressView, scrollView, contentsView, footerView, timeLabel 등), 레이아웃, UI 업데이트 메서드를 `ExamTestView`로 추출한다.

```swift
// ExamTestView.swift
final class ExamTestView: UIView {
    let footerView = ExamTestFooterView()
    private(set) var contentsView: TestContentsView!
    // progressView, timeLabel, totalTimeRemainingLabel ...

    func updateQuestion(_ question: QuestionData) { ... }
    func updateTotalPage(_ totalPage: Int) { ... }
    func updateProgress(timeLimit: Int, timeRemaining: Int) { ... }
    func updateOptionState(at optionIdx: Int, isSelected: Bool) { ... }
    func updatePrevButton(isEnabled: Bool) { ... }
    func updateNextButton(isEnabled: Bool) { ... }
}
```

`ExamTestViewModel`에서 debug print 제거:
- `print("EXIT TIMER")` 삭제
- `print("DEINIT: ExamTestViewModel")` 삭제

---

## ExamResult — DailyResult 패턴 적용

### ExamResultViewModel 전환

`Input/Output` Combine 패턴 → `ObservableObject` + delegate 패턴.

```swift
@MainActor
protocol ExamResultViewModelDelegate: AnyObject {
    func didRequestQuitExam()
    func didRequestMoveToConcept()
    func didRequestMoveToResultDetail()
    func didRequestShowProblemDetail(questionId: Int)
}

@MainActor
final class ExamResultViewModel: ObservableObject {
    @Published var errorMessage: String?

    let resultScoresData = ResultScoresData()
    let resultGradeListData = ResultGradeListData()
    let resultDetailData = ResultDetailData()
    let scoreGraphData = ScoreGraphData()

    weak var delegate: ExamResultViewModelDelegate?

    private let examId: Int
    private let examService: any ExamService
    private var fetchTask: Task<Void, Never>?

    init(examId: Int, examService: any ExamService) { ... }

    func onViewDidLoad() {
        fetchTask?.cancel()
        fetchTask = Task { await fetchData() }
    }

    func didTapCancel() { delegate?.didRequestQuitExam() }
    func didTapMoveToConcept() { delegate?.didRequestMoveToConcept() }
    func didTapResultDetail() { delegate?.didRequestMoveToResultDetail() }
    func didTapProblem(questionId: Int) { delegate?.didRequestShowProblemDetail(questionId: questionId) }

    private func fetchData() async { ... }

    private func updateData() {
        Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard let self else { return }
            // observable 객체 업데이트
        }
    }
}
```

`DispatchQueue.main.asyncAfter` → `Task { @MainActor }` 로 교체.

### ExamResultView 수정

`PassthroughSubject` publisher 제거. ViewModel 직접 호출로 전환:

```swift
struct ExamResultView: View {
    @ObservedObject var viewModel: ExamResultViewModel

    var body: some View {
        // viewModel.didTapCancel() 등 직접 호출
    }
}
```

`ExamResultHostingController`, `ExamResultViewController` 삭제.

### ExamCoordinatorImpl — ExamResult 생성

```swift
// ExamCoordinatorImpl.swift
private var examResultViewModel: ExamResultViewModel?  // 조기 해제 방지

func showExamResult() {
    guardNavigation {
        let vm = ExamResultViewModel(examId: self.currentExamId, examService: self.examService)
        vm.delegate = self
        self.examResultViewModel = vm
        let vc = UIHostingController(rootView: ExamResultView(viewModel: vm))
        vc.hidesBottomBarWhenPushed = true
        self.navigationController.pushViewController(vc, animated: true)
    }
}
```

```swift
extension ExamCoordinatorImpl: ExamResultViewModelDelegate {
    func didRequestQuitExam() { quitExam() }
    func didRequestMoveToConcept() { ... }
    func didRequestMoveToResultDetail() { showResultDetail() }
    func didRequestShowProblemDetail(questionId: Int) { showProblemExplanation(questionId: questionId) }
}
```

---

## HomeCoordinator 수정

`ExamCoordinatorImpl` 직접 참조 → `makeExamCoordinator` factory 사용. 나머지 구조(같은 navigationController 사용, childCoordinators append, delegate 설정)는 동일.

```swift
import Exam  // 추가

func showExam() {
    guard let navi = navigationController else { return }
    guardNavigation {
        var exam = makeExamCoordinator(
            navigationController: navi,
            examService: self.examTestService
        )
        exam.delegate = self
        self.childCoordinators.append(exam)
        _ = exam.start()
    }
}
```

`ExamCoordinatorDelegate` 준수는 기존과 동일하게 extension으로 유지.
```

---

## 수정 후 삭제 목록

- `ExamResultHostingController.swift`
- `ExamResultViewController.swift`
- `QRIZ/Feature/Exam/` 전체
