import Testing
import SwiftUI
import UIKit
@testable import DesignSystem

@MainActor
@Suite("QRIZNavigationController 테스트", .serialized)
struct QRIZNavigationControllerTests {

    // MARK: - Helpers

    private func makeSUT(usesSystemGlass: Bool = true) -> (sut: QRIZNavigationController, root: UIViewController) {
        let root = UIViewController()
        let sut = QRIZNavigationController(rootViewController: root)
        sut.usesSystemGlass = usesSystemGlass
        _ = sut.view // 뷰를 로드해 interactivePopGestureRecognizer를 준비한다
        return (sut, root)
    }

    // MARK: - 뒤로가기 버튼 설치

    @Test("glass 사용 시 push된 화면에 원형 glass 뒤로가기 버튼(GlassIconButton)이 설치된다")
    func installsBackItemOnPushedScreen() throws {
        let (sut, _) = makeSUT()
        let pushed = UIViewController()

        sut.pushViewController(pushed, animated: false)

        let item = try #require(pushed.navigationItem.leftBarButtonItem)
        #expect(item.customView is GlassIconButton)
    }

    @Test("설치 시 leftItemsSupplementBackButton을 false로 맞춘다")
    func setsSupplementBackButtonToFalseOnInstall() {
        let (sut, _) = makeSUT()
        let pushed = UIViewController()

        sut.pushViewController(pushed, animated: false)

        #expect(pushed.navigationItem.leftItemsSupplementBackButton == false)
    }

    @Test("루트 화면에는 설치되지 않는다")
    func doesNotInstallOnRoot() {
        let (_, root) = makeSUT()

        #expect(root.navigationItem.leftBarButtonItem == nil)
    }

    @Test("glass를 쓰지 않으면 시스템 뒤로가기를 그대로 둔다")
    func keepsSystemBackWhenGlassUnsupported() {
        let (sut, _) = makeSUT(usesSystemGlass: false)
        let pushed = UIViewController()

        sut.pushViewController(pushed, animated: false)

        #expect(pushed.navigationItem.leftBarButtonItem == nil)
    }

    @Test("ManagesOwnLeadingBarItem을 채택한 화면에는 뒤로가기 버튼을 설치하지 않는다")
    func doesNotInstallOnScreenManagingItsOwnLeadingItem() {
        final class CancelScreen: UIViewController, ManagesOwnLeadingBarItem {}
        let (sut, _) = makeSUT()
        let pushed = CancelScreen()
        pushed.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "취소", style: .plain, target: nil, action: nil)

        sut.pushViewController(pushed, animated: false)

        #expect(pushed.navigationItem.leftBarButtonItem?.title == "취소")
    }

    @Test("ManagesOwnLeadingBarItem을 채택한 화면도 시스템 보조 뒤로가기 표시는 꺼진다")
    func suppressesSupplementBackButtonEvenOnScreenManagingItsOwnLeadingItem() {
        final class CancelScreen: UIViewController, ManagesOwnLeadingBarItem {}
        let (sut, _) = makeSUT()
        let pushed = CancelScreen()

        sut.pushViewController(pushed, animated: false)

        #expect(pushed.navigationItem.leftItemsSupplementBackButton == false)
    }

    @Test("방어적으로: 채택하지 않은 화면도 이미 왼쪽 버튼이 있으면 덮어쓰지 않는다")
    func keepsExistingLeftItemEvenWithoutOptOut() {
        let (sut, _) = makeSUT()
        let pushed = UIViewController()
        let existing = UIBarButtonItem(title: "취소", style: .plain, target: nil, action: nil)
        pushed.navigationItem.leftBarButtonItem = existing

        sut.pushViewController(pushed, animated: false)

        #expect(pushed.navigationItem.leftBarButtonItem === existing)
    }

    @Test("방어적으로: 채택하지 않은 화면도 뒤로가기를 숨겼다면 설치하지 않는다")
    func respectsHiddenBackButtonEvenWithoutOptOut() {
        let (sut, _) = makeSUT()
        let pushed = UIViewController()
        pushed.navigationItem.hidesBackButton = true

        sut.pushViewController(pushed, animated: false)

        #expect(pushed.navigationItem.leftBarButtonItem == nil)
    }

    @Test("설치된 뒤로가기 버튼을 누르면 pop된다")
    func backItemPopsScreen() throws {
        let (sut, root) = makeSUT()
        let pushed = UIViewController()
        sut.pushViewController(pushed, animated: false)

        let item = try #require(pushed.navigationItem.leftBarButtonItem)
        let button = try #require(item.customView as? GlassIconButton)
        button.sendActions(for: .touchUpInside)

        #expect(sut.viewControllers == [root])
    }

    @Test("설치된 뒤로가기 버튼에는 접근성 라벨이 있다")
    func backItemHasAccessibilityLabel() throws {
        let (sut, _) = makeSUT()
        let pushed = UIViewController()
        sut.pushViewController(pushed, animated: false)

        #expect(pushed.navigationItem.leftBarButtonItem?.accessibilityLabel == "뒤로")
    }

    // MARK: - 아이콘 지정

    @Test("아이콘을 지정하지 않은 화면은 chevron.left를 쓴다")
    func defaultBackImageName() {
        let (sut, _) = makeSUT()

        #expect(sut.backButtonImageName(for: UIViewController()) == "chevron.left")
    }

    @Test("BackButtonImageProviding을 채택한 화면은 지정한 아이콘을 쓴다")
    func customBackImageName() {
        final class CloseScreen: UIViewController, BackButtonImageProviding {
            var backButtonSystemImageName: String { "xmark" }
        }
        let (sut, _) = makeSUT()

        #expect(sut.backButtonImageName(for: CloseScreen()) == "xmark")
    }

    // MARK: - 스와이프 뒤로가기

    @Test("우리가 설치한 뒤로가기 화면에서는 스와이프 뒤로가기가 허용된다")
    func swipeBackAllowedOnInstalledScreen() throws {
        let (sut, _) = makeSUT()
        sut.pushViewController(UIViewController(), animated: false)
        let gesture = try #require(sut.interactivePopGestureRecognizer)

        #expect(sut.gestureRecognizerShouldBegin(gesture) == true)
    }

    @Test("루트 화면에서는 스와이프 뒤로가기가 시작되지 않는다")
    func swipeBackBlockedOnRoot() throws {
        let (sut, _) = makeSUT()
        let gesture = try #require(sut.interactivePopGestureRecognizer)

        #expect(sut.gestureRecognizerShouldBegin(gesture) == false)
    }

    @Test("ManagesOwnLeadingBarItem을 채택한 화면은 스와이프 뒤로가기를 막는다")
    func swipeBackBlockedOnScreenManagingItsOwnLeadingItem() throws {
        final class CancelScreen: UIViewController, ManagesOwnLeadingBarItem {}
        let (sut, _) = makeSUT()
        sut.pushViewController(CancelScreen(), animated: false)
        let gesture = try #require(sut.interactivePopGestureRecognizer)

        #expect(sut.gestureRecognizerShouldBegin(gesture) == false)
    }

    @Test("glass를 쓰지 않으면 시스템 동작대로 스와이프 뒤로가기가 허용된다")
    func swipeBackAllowedWithSystemBack() throws {
        let (sut, _) = makeSUT(usesSystemGlass: false)
        sut.pushViewController(UIViewController(), animated: false)
        let gesture = try #require(sut.interactivePopGestureRecognizer)

        #expect(sut.gestureRecognizerShouldBegin(gesture) == true)
    }

    // MARK: - SwiftUI 화면 (진단)

    /// DailyResultView/ExamResultView와 동일한 패턴: ManagesOwnLeadingBarItem을 채택해 자체 X 버튼을
    /// 관리하는 SwiftUI 화면도, 비동기 데이터 로딩 등으로 재렌더링되면 시스템 보조 뒤로가기 표시를
    /// 다시 true로 되돌릴 수 있다. 이 화면은 왼쪽 버튼 자체는 우리가 건드리지 않지만, 보조 표시만큼은
    /// 계속 꺼져 있어야 한다.
    @Test("ManagesOwnLeadingBarItem을 채택한 SwiftUI 화면도 재렌더링 후 보조 뒤로가기가 다시 보이지 않는다")
    func managedSwiftUIScreenStaysSuppressedAfterRerender() async throws {
        final class ResultLikeHost<Content: View>: UIHostingController<Content>, ManagesOwnLeadingBarItem {}

        let (sut, _) = makeSUT()
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 402, height: 874))
        window.rootViewController = sut
        window.makeKeyAndVisible()

        final class ViewModel: ObservableObject {
            @Published var text = "초기"
        }
        struct ResultLikeView: View {
            @ObservedObject var viewModel: ViewModel
            var body: some View {
                Text(viewModel.text)
                    .navigationBarBackButtonHidden(true)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("닫기") {}
                        }
                    }
            }
        }
        let viewModel = ViewModel()
        let hosting = ResultLikeHost(rootView: ResultLikeView(viewModel: viewModel))
        sut.pushViewController(hosting, animated: false)
        try await Task.sleep(nanoseconds: 500_000_000)

        // 비동기 데이터 도착으로 인한 재렌더링을 재현한다.
        viewModel.text = "재렌더링"
        try await Task.sleep(nanoseconds: 300_000_000)

        #expect(hosting.navigationItem.leftItemsSupplementBackButton == false)
    }

    /// ManagesOwnLeadingBarItem을 채택하지 않은 "평범한" SwiftUI 화면(자체 toolbar 없음)에서,
    /// 설치 시 한 번만 false로 맞춘 leftItemsSupplementBackButton이 이후 재렌더링에도 유지되는지 확인한다.
    @Test("자체 toolbar가 없는 SwiftUI 화면은 재렌더링 후에도 뒤로가기가 하나만 보인다")
    func plainSwiftUIScreenStaysSingleButtonAfterRerender() async throws {
        let (sut, _) = makeSUT()
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 402, height: 874))
        window.rootViewController = sut
        window.makeKeyAndVisible()

        final class ViewModel: ObservableObject {
            @Published var text = "초기"
        }
        struct PlainView: View {
            @ObservedObject var viewModel: ViewModel
            var body: some View { Text(viewModel.text) }
        }
        let viewModel = ViewModel()
        let hosting = UIHostingController(rootView: PlainView(viewModel: viewModel))
        sut.pushViewController(hosting, animated: false)
        try await Task.sleep(nanoseconds: 500_000_000)

        // 비동기 데이터 도착 등으로 SwiftUI가 재렌더링되는 상황을 재현한다.
        viewModel.text = "재렌더링"
        try await Task.sleep(nanoseconds: 300_000_000)

        #expect(hosting.navigationItem.leftItemsSupplementBackButton == false)
        #expect(hosting.navigationItem.leftBarButtonItem?.customView is GlassIconButton)
    }
}
