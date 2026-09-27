//
//  ExamResultNavigationTests.swift
//  QRIZ
//

import Testing
import SwiftUI
@testable import Exam
import DesignSystem
import QRIZUtils

/// `ExamResultView`를 실제 프로덕션과 동일하게 `QRIZNavigationController`에 push했을 때,
/// 뒤로가기(원형 glass)와 화면 자체의 X 버튼이 함께 보이지 않는지 검증한다.
///
/// 배경: SwiftUI가 비동기 데이터 로딩 등으로 재렌더링되면 `leftItemsSupplementBackButton`을
/// 다시 true로 되돌릴 수 있는데, 이를 계속 감시해 꺼주지 못하면 시스템이 X 옆에 뒤로가기를
/// 자동으로 함께 그린다.
@MainActor
@Suite("ExamResultView 내비게이션 테스트", .serialized)
struct ExamResultNavigationTests {

    private func makeViewModel() -> ExamResultViewModel {
        ExamResultViewModel(
            examId: 1,
            examService: MockExamService(),
            reviewPromptService: MockReviewPromptService(),
            userInfo: .shared
        )
    }

    @Test("초기 렌더링 이후 재렌더링되어도 뒤로가기가 X 옆에 함께 보이지 않는다")
    func doesNotShowBackButtonAlongsideCloseButtonAfterRerender() async throws {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 402, height: 874))
        let nav = QRIZNavigationController(rootViewController: UIViewController())
        window.rootViewController = nav
        window.makeKeyAndVisible()

        let viewModel = makeViewModel()
        let hosting = UIHostingController(rootView: ExamResultView(viewModel: viewModel))
        nav.pushViewController(hosting, animated: false)
        try await Task.sleep(nanoseconds: 500_000_000)

        // 데이터가 비동기로 도착해 SwiftUI가 재렌더링되는 상황을 재현한다.
        viewModel.errorMessage = "재렌더링 트리거"
        try await Task.sleep(nanoseconds: 200_000_000)
        viewModel.errorMessage = nil
        try await Task.sleep(nanoseconds: 200_000_000)

        #expect(hosting.navigationItem.leftItemsSupplementBackButton == false)
    }
}
