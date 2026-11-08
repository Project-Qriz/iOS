//
//  PreviewResultNavigationTests.swift
//  QRIZ
//

import Testing
import SwiftUI
import DesignSystem
import QRIZUtils
@testable import Onboarding

/// 프리뷰 결과 화면을 push했을 때 왼쪽에 X 버튼만 남고 뒤로가기가 함께 보이지 않는지 검증한다.
@MainActor
@Suite("PreviewResultView 내비게이션 테스트", .serialized)
struct PreviewResultNavigationTests {

    private func makeViewModel(onClose: @escaping () -> Void = {}) -> PreviewResultViewModel {
        PreviewResultViewModel(
            onboardingService: MockOnboardingService(),
            onNavigateToGreeting: onClose,
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

    private func push(_ viewController: UIViewController) async throws {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 402, height: 874))
        let nav = QRIZNavigationController(rootViewController: UIViewController())
        // glass 미지원 OS에서도 뒤로가기 설치 경로를 검증하도록 강제로 켠다.
        nav.usesSystemGlass = true
        window.rootViewController = nav
        window.makeKeyAndVisible()
        nav.pushViewController(viewController, animated: false)
        try await Task.sleep(nanoseconds: 500_000_000)
    }

    @Test("왼쪽에는 X 버튼 하나만 있고 뒤로가기는 보이지 않는다")
    func showsOnlyCloseButton() async throws {
        let viewModel = makeViewModel()
        let hosting = PreviewResultHostingController(rootView: PreviewResultView(viewModel: viewModel))
        try await push(hosting)

        // 데이터가 비동기로 도착해 SwiftUI가 재렌더링되는 상황을 재현한다.
        viewModel.errorMessage = "재렌더링 트리거"
        try await Task.sleep(nanoseconds: 200_000_000)
        viewModel.errorMessage = nil
        try await Task.sleep(nanoseconds: 200_000_000)

        #expect(hosting.navigationItem.leftItemsSupplementBackButton == false)
        #expect(glassButtonLabels(hosting.navigationItem) == ["닫기"])
    }

    @Test("X 버튼을 누르면 다음 단계로 이동한다")
    func closeButtonNavigatesToNextStep() async throws {
        var closed = false
        let viewModel = makeViewModel(onClose: { closed = true })
        let hosting = PreviewResultHostingController(rootView: PreviewResultView(viewModel: viewModel))
        try await push(hosting)

        let button = try #require(hosting.navigationItem.leftBarButtonItem?.customView as? GlassIconButton)
        button.sendActions(for: .touchUpInside)

        #expect(closed)
    }
}
