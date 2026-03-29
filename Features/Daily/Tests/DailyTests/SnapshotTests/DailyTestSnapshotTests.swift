//
//  DailyTestSnapshotTests.swift
//  QRIZ
//

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
        // DailyTestViewController를 navigation controller로 래핑해 타이머 레이블과 취소 버튼을 포함한 스냅샷
        let vm = DailyTestViewModel(day: 1, dailyService: MockDailyService())
        let vc = DailyTestViewController(viewModel: vm)
        let nav = inDailyNav(vc)
        vc.loadViewIfNeeded()
        // viewDidLoad()가 startTask를 시작하기 전에 동기적으로 상태 설정
        let contentView = vc.view as! DailyTestView
        contentView.updateQuestion(sampleQuestion(number: 1))
        contentView.updateTotalPage(3)
        contentView.setButtonsVisibility(isVisible: false)
        assertSnapshot(of: nav, as: .image(size: Self.deviceSize))
    }
}
