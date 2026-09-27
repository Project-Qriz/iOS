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
/// 배경: `leftBarButtonItem`을 설정하면 iOS 16+ `leadingItemGroups`에도 그룹으로 미러링되는데,
/// SwiftUI의 `.toolbar { ToolbarItem(placement: .navigationBarLeading) { ... } }`는 이 배열을
/// 교체가 아니라 "추가"하는 방식으로 동작한다. 그래서 화면이 자기 왼쪽 버튼(X)을 넣어도 우리가 설치한
/// 뒤로가기 그룹이 배열에 그대로 남아 함께 보일 수 있다. 게다가 이 시점부터는 `leftBarButtonItem`이
/// 항상 nil을 반환해, `leftBarButtonItem`만 비교하는 검사로는 이 문제를 절대 잡아낼 수 없다.
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

    /// `leftBarButtonItem`을 설정하면 iOS 16+ `leadingItemGroups`에도 미러링되는데, 화면이 SwiftUI
    /// `.toolbar`로 자기 왼쪽 아이템을 추가하면 그 순간부터 `leftBarButtonItem`은 항상 nil을 반환한다.
    /// 그래서 뒤로가기가 실제로 남아있는지는 leadingItemGroups까지 확인해야 정확히 알 수 있다.
    private func hasGlassBackButtonInstalled(_ item: UINavigationItem) -> Bool {
        if item.leftBarButtonItem?.customView is GlassIconButton { return true }
        return item.leadingItemGroups
            .flatMap(\.barButtonItems)
            .contains { $0.customView is GlassIconButton }
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
        #expect(!hasGlassBackButtonInstalled(hosting.navigationItem))
    }

    /// `ExamTestViewController`가 결과 화면으로 넘어가기 직전에 실제로 거치는 순서를 그대로 재현한다:
    /// 1) `removeNavigationItems()`로 자신의 "취소" 버튼을 nil로 지운다 (`ExamTestViewController.swift:99`)
    /// 2) 제출 확인 알럿을 dismiss한다
    /// 3) dismiss 완료 후 전면 광고를 모달로 띄웠다가 닫는다
    /// 4) 광고가 닫히면 `ExamResultView`를 push한다
    @Test("제출 확인 알럿 dismiss + 전면 광고 표시/해제 이후 push해도 뒤로가기와 X가 함께 보이지 않는다")
    func doesNotShowBothButtonsAfterAlertDismissAndAdPresentation() async throws {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 402, height: 874))
        let nav = QRIZNavigationController(rootViewController: UIViewController())
        window.rootViewController = nav
        window.makeKeyAndVisible()

        // 1) ExamTestViewController를 흉내낸 화면: 자체 "취소" 버튼을 갖고 push된다.
        let examTestLike = UIViewController()
        examTestLike.navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "취소", style: .plain, target: nil, action: nil
        )
        nav.pushViewController(examTestLike, animated: false)
        try await Task.sleep(nanoseconds: 200_000_000)

        // 2) 제출 확인 알럿(모달)이 떠 있는 상태를 재현한다.
        // 유닛 테스트 환경(호스트 앱 없음)에서는 애니메이션 완료 콜백이 불안정하므로 animated: false로 진행한다.
        let submitAlertLike = UIViewController()
        nav.present(submitAlertLike, animated: false)
        try await Task.sleep(nanoseconds: 200_000_000)

        // removeNavigationItems(): 알럿을 닫기 *직전에* 자신의 좌측 버튼을 지운다.
        examTestLike.navigationItem.leftBarButtonItem = nil
        examTestLike.navigationItem.rightBarButtonItems = nil

        submitAlertLike.dismiss(animated: false)
        try await Task.sleep(nanoseconds: 200_000_000)

        // showExamResult(): 전면 광고를 모달로 띄웠다가, 사용자가 보고 닫는 상황을 재현한다.
        let adLike = UIViewController()
        nav.present(adLike, animated: false)
        try await Task.sleep(nanoseconds: 200_000_000)
        adLike.dismiss(animated: false)
        try await Task.sleep(nanoseconds: 200_000_000)

        let viewModel = makeViewModel()
        let hosting = UIHostingController(rootView: ExamResultView(viewModel: viewModel))
        nav.pushViewController(hosting, animated: false)
        try await Task.sleep(nanoseconds: 500_000_000)

        // 비동기 데이터 도착으로 인한 재렌더링까지 재현한다.
        viewModel.errorMessage = "재렌더링 트리거"
        try await Task.sleep(nanoseconds: 200_000_000)
        viewModel.errorMessage = nil
        try await Task.sleep(nanoseconds: 200_000_000)

        #expect(hosting.navigationItem.leftItemsSupplementBackButton == false)
        #expect(!hasGlassBackButtonInstalled(hosting.navigationItem))
    }
}
