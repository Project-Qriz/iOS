import XCTest
import SnapshotTesting
@testable import Daily
import QRIZUtils

@MainActor
final class DailyTestSnapshotTests: DailySnapshotTestCase {

    private func makeView() -> DailyTestView {
        let view = DailyTestView()
        view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        view.updateTotalPage(3)
        return view
    }

    private func sampleQuestion(number: Int) -> QuestionData {
        QuestionData(
            question: "다음 중 엔터티의 특징으로 옳지 않은 것은?",
            option1: "반드시 속성을 가져야 한다.",
            option2: "유일한 식별자가 있어야 한다.",
            option3: "두 개 이상의 인스턴스가 존재해야 한다.",
            option4: "업무에서 관리해야 하는 정보여야 한다.",
            timeLimit: 70,
            questionNumber: number
        )
    }

    func test_firstQuestion_buttonHidden() {
        let view = makeView()
        view.updateQuestion(sampleQuestion(number: 1))
        view.setButtonsVisibility(isVisible: false)
        assertSnapshot(of: view, as: .image(size: Self.deviceSize))
    }

    func test_firstQuestion_buttonVisible() {
        let view = makeView()
        view.updateQuestion(sampleQuestion(number: 1))
        view.setButtonsVisibility(isVisible: true)
        view.updateOptionState(at: 2, isSelected: true)
        assertSnapshot(of: view, as: .image(size: Self.deviceSize))
    }

    func test_middleQuestion() {
        let view = makeView()
        view.updateQuestion(sampleQuestion(number: 2))
        view.setButtonsVisibility(isVisible: true)
        assertSnapshot(of: view, as: .image(size: Self.deviceSize))
    }

    func test_lastQuestion_submitButton() {
        let view = makeView()
        view.updateQuestion(sampleQuestion(number: 3))
        view.setButtonsVisibility(isVisible: true)
        view.alterButtonText()
        assertSnapshot(of: view, as: .image(size: Self.deviceSize))
    }

    func test_optionSelected() {
        let view = makeView()
        view.updateQuestion(sampleQuestion(number: 1))
        view.setButtonsVisibility(isVisible: false)
        view.updateOptionState(at: 3, isSelected: true)
        assertSnapshot(of: view, as: .image(size: Self.deviceSize))
    }

    func test_withNavigationBar() {
        // navigation bar의 취소 버튼과 타이머 barButtonItem을 포함한 스냅샷.
        // viewDidLoad()가 시작하는 fetchData Task는 VC의 .receive(on: DispatchQueue.main)을 통해
        // 메인 큐에 비동기 dispatch되므로, 이후의 동기적 상태 설정과 assertSnapshot이 먼저 실행된다.
        let vm = DailyTestViewModel(day: 1, dailyService: MockDailyService())
        let vc = DailyTestViewController(viewModel: vm)
        let nav = inDailyNav(vc)
        vc.loadViewIfNeeded()
        guard let contentView = vc.view as? DailyTestView else {
            XCTFail("vc.view is not DailyTestView")
            return
        }
        contentView.updateQuestion(sampleQuestion(number: 1))
        contentView.updateTotalPage(3)
        contentView.setButtonsVisibility(isVisible: false)
        assertSnapshot(of: nav, as: .image(size: Self.deviceSize))
    }
}
