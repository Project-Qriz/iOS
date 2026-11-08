//
//  ExamResultNavigationTests.swift
//  QRIZ
//

import Testing
import SwiftUI
@testable import Exam
import DesignSystem
import QRIZUtils

/// `QRIZNavigationController`에 push해도 왼쪽에 X 버튼만 남고 뒤로가기는 보이지 않는지 검증한다.
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

    /// `leftBarButtonItem`과 `leadingItemGroups`의 glass 버튼 접근성 라벨을 모은다.
    private func glassButtonLabels(_ item: UINavigationItem) -> [String] {
        var items: [UIBarButtonItem] = []
        if let left = item.leftBarButtonItem { items.append(left) }
        items += item.leadingItemGroups.flatMap(\.barButtonItems)
        return items
            .filter { $0.customView is GlassIconButton }
            .compactMap(\.accessibilityLabel)
    }

    @Test("초기 렌더링 이후 재렌더링되어도 왼쪽에는 X 버튼 하나만 있고 뒤로가기는 보이지 않는다")
    func showsOnlyCloseButtonAfterRerender() async throws {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 402, height: 874))
        let nav = QRIZNavigationController(rootViewController: UIViewController())
        window.rootViewController = nav
        window.makeKeyAndVisible()

        let viewModel = makeViewModel()
        let hosting = ExamResultHostingController(rootView: ExamResultView(viewModel: viewModel))
        nav.pushViewController(hosting, animated: false)
        try await Task.sleep(nanoseconds: 500_000_000)

        // 데이터가 비동기로 도착해 SwiftUI가 재렌더링되는 상황을 재현한다.
        viewModel.errorMessage = "재렌더링 트리거"
        try await Task.sleep(nanoseconds: 200_000_000)
        viewModel.errorMessage = nil
        try await Task.sleep(nanoseconds: 200_000_000)

        #expect(hosting.navigationItem.leftItemsSupplementBackButton == false)
        #expect(glassButtonLabels(hosting.navigationItem) == ["닫기"])
    }
}
