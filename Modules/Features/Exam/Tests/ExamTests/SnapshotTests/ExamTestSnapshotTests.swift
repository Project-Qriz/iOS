//
//  ExamTestSnapshotTests.swift
//  QRIZ
//

import UIKit
import XCTest
import SnapshotTesting
@testable import Exam
import QRIZNetwork
import QRIZUtils

@MainActor
class ExamTestSnapshotTests: ExamSnapshotTestCase {

    // MARK: - Helpers

    // Note: makeKeyAndVisible()을 호출하지 않아 safeAreaLayoutGuide 인셋이 0으로 렌더링됨.
    // 실기기 레이아웃과 다를 수 있으나 프로젝트 전체 스냅샷 테스트의 공통 전제임.
    private func makeExamTestView(
        questionNumber: Int = 1,
        totalPage: Int = 3,
        selectedOption: Int? = nil,
        prevVisible: Bool = false,
        nextVisible: Bool = false,
        isLastPage: Bool = false
    ) -> ExamTestView {
        let view = ExamTestView()
        view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        view.updateTotalPage(totalPage)
        // updateQuestion은 문제 텍스트와 페이지 번호를 갱신함.
        // selectedOption은 QuestionData에 데이터 상태로 보관되며,
        // UI 강조 표시는 아래 updateOptionState로 별도 적용함.
        view.updateQuestion(QuestionData(
            question: "다음 중 엔터티 분류에 대한 설명으로 가장 올바른 것은?",
            option1: "기본 엔터티는 항상 발생 엔터티의 부모 엔터티가 된다.",
            option2: "중심 엔터티는 업무에서 중요한 엔터티만을 의미한다.",
            option3: "행위 엔터티는 두 개 이상의 엔터티로부터 발생되는 엔터티이다.",
            option4: "코드 엔터티는 반드시 기본 엔터티여야 한다.",
            timeLimit: 60,
            questionNumber: questionNumber,
            selectedOption: selectedOption
        ))
        view.updatePrevButton(isVisible: prevVisible)
        view.updateNextButton(isVisible: nextVisible, isTextSubmit: isLastPage)
        if let selectedOption {
            view.updateOptionState(at: selectedOption, isSelected: true)
        }
        view.layoutIfNeeded()
        return view
    }

    private func makeConfiguredNav() -> UINavigationController {
        let service = MockExamService()
        service.getExamQuestionResult = .success(MockExamService.makeExamQuestion())
        let vm = ExamTestViewModel(examId: 1, examService: service)
        let vc = ExamTestViewController(viewModel: vm)
        return inExamNav(vc)
    }

    // MARK: - ExamTestView 스냅샷

    func testExamTestView_firstPage_noSelection() {
        let view = makeExamTestView(prevVisible: false, nextVisible: false)
        assertSnapshot(of: view, as: .image)
    }

    func testExamTestView_firstPage_withSelection() {
        let view = makeExamTestView(selectedOption: 2, prevVisible: false, nextVisible: true)
        assertSnapshot(of: view, as: .image)
    }

    func testExamTestView_middlePage() {
        let view = makeExamTestView(questionNumber: 2, prevVisible: true, nextVisible: true)
        assertSnapshot(of: view, as: .image)
    }

    func testExamTestView_lastPage() {
        let view = makeExamTestView(
            questionNumber: 3,
            selectedOption: 1,
            prevVisible: true,
            nextVisible: true,
            isLastPage: true
        )
        assertSnapshot(of: view, as: .image)
    }

    // MARK: - ExamTestViewController 스냅샷

    func testExamTestViewController() async throws {
        let nav = makeConfiguredNav()
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)
        nav.view.layoutIfNeeded()
        assertSnapshot(of: nav, as: .image(on: .iPhone16Pro))
    }
}
