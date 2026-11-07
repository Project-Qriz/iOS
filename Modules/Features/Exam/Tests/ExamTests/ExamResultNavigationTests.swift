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
/// 뒤로가기(원형 glass)는 설치되지 않고 화면 자체의 X 버튼만 남는지 검증한다.
///
/// 배경: `leftBarButtonItem`을 설정하면 iOS 16+ `leadingItemGroups`에도 그룹으로 미러링된다.
/// SwiftUI `.toolbar`의 leading 아이템은 이 배열을 교체가 아니라 "추가"하므로, 화면이 SwiftUI로
/// 자기 왼쪽 버튼을 넣으면 우리가 설치한 뒤로가기 그룹이 남아 함께 보일 수 있다.
/// X 버튼은 UIKit `navigationItem`에 설치하고 SwiftUI `.toolbar`에는 제목만 두므로,
/// 재렌더링 이후에도 왼쪽에는 X 하나만 있어야 한다.
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

    /// 왼쪽 영역의 모든 glass 버튼 아이템의 접근성 라벨을 모은다.
    /// `leftBarButtonItem`과 `leadingItemGroups`(iOS 16+ 미러링)를 모두 확인한다.
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
