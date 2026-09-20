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

    private func installedBackItem(on vc: UIViewController) -> UIBarButtonItem? {
        vc.navigationItem.leftBarButtonItem.flatMap { $0 is QRIZNavigationController.BackBarButtonItem ? $0 : nil }
    }

    // MARK: - 뒤로가기 버튼 설치

    @Test("glass 사용 시 push된 화면에 커스텀 뒤로가기 버튼이 설치된다")
    func installsBackItemOnPushedScreen() {
        let (sut, _) = makeSUT()
        let pushed = UIViewController()

        sut.pushViewController(pushed, animated: false)

        #expect(installedBackItem(on: pushed) != nil)
    }

    @Test("설치해도 화면의 hidesBackButton은 건드리지 않는다 (화면이 나중에 숨기는 것을 감지하기 위함)")
    func doesNotTouchHidesBackButton() {
        let (sut, _) = makeSUT()
        let pushed = UIViewController()

        sut.pushViewController(pushed, animated: false)

        #expect(pushed.navigationItem.hidesBackButton == false)
    }

    @Test("설치 후 화면이 뒤로가기를 숨기면 설치한 버튼을 치운다")
    func removesInstalledItemWhenScreenHidesBackButtonLater() {
        let (sut, _) = makeSUT()
        let pushed = UIViewController()
        sut.pushViewController(pushed, animated: false)
        #expect(installedBackItem(on: pushed) != nil)

        pushed.navigationItem.hidesBackButton = true

        #expect(pushed.navigationItem.leftBarButtonItem == nil)
    }

    @Test("루트 화면에는 설치되지 않는다")
    func doesNotInstallOnRoot() {
        let (_, root) = makeSUT()

        #expect(installedBackItem(on: root) == nil)
        #expect(root.navigationItem.leftBarButtonItem == nil)
    }

    @Test("glass를 쓰지 않으면 시스템 뒤로가기를 그대로 둔다")
    func keepsSystemBackWhenGlassUnsupported() {
        let (sut, _) = makeSUT(usesSystemGlass: false)
        let pushed = UIViewController()

        sut.pushViewController(pushed, animated: false)

        #expect(pushed.navigationItem.leftBarButtonItem == nil)
        #expect(pushed.navigationItem.hidesBackButton == false)
    }

    @Test("화면이 자기 왼쪽 버튼을 이미 가지고 있으면 덮어쓰지 않는다")
    func keepsExistingLeftItem() {
        let (sut, _) = makeSUT()
        let pushed = UIViewController()
        let cancel = UIBarButtonItem(title: "취소", style: .plain, target: nil, action: nil)
        pushed.navigationItem.leftBarButtonItem = cancel

        sut.pushViewController(pushed, animated: false)

        #expect(pushed.navigationItem.leftBarButtonItem === cancel)
    }

    @Test("화면이 뒤로가기를 숨겼다면 설치하지 않는다")
    func respectsHiddenBackButton() {
        let (sut, _) = makeSUT()
        let pushed = UIViewController()
        pushed.navigationItem.hidesBackButton = true

        sut.pushViewController(pushed, animated: false)

        #expect(installedBackItem(on: pushed) == nil)
    }

    @Test("설치된 뒤로가기 버튼을 누르면 pop된다")
    func backItemPopsScreen() throws {
        let (sut, root) = makeSUT()
        let pushed = UIViewController()
        sut.pushViewController(pushed, animated: false)

        let item = try #require(installedBackItem(on: pushed))
        let action = try #require(item.primaryAction)
        action.performWithSender(nil, target: nil)

        #expect(sut.viewControllers == [root])
    }

    @Test("설치된 뒤로가기 버튼에는 접근성 라벨이 있다")
    func backItemHasAccessibilityLabel() throws {
        let (sut, _) = makeSUT()
        let pushed = UIViewController()
        sut.pushViewController(pushed, animated: false)

        let item = try #require(installedBackItem(on: pushed))

        #expect(item.accessibilityLabel == "뒤로")
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

    @Test("자체 왼쪽 버튼(취소 등)이 있는 화면은 스와이프 뒤로가기를 계속 막는다")
    func swipeBackBlockedOnCustomLeftItem() throws {
        let (sut, _) = makeSUT()
        let exam = UIViewController()
        exam.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "취소", style: .plain, target: nil, action: nil)
        sut.pushViewController(exam, animated: false)
        let gesture = try #require(sut.interactivePopGestureRecognizer)

        #expect(sut.gestureRecognizerShouldBegin(gesture) == false)
    }

    @Test("뒤로가기를 숨긴 화면은 스와이프 뒤로가기를 계속 막는다")
    func swipeBackBlockedOnHiddenBackButton() throws {
        let (sut, _) = makeSUT()
        let hidden = UIViewController()
        hidden.navigationItem.hidesBackButton = true
        sut.pushViewController(hidden, animated: false)
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

    // MARK: - SwiftUI 화면

    @Test("SwiftUI 호스팅 화면에서도 커스텀 뒤로가기 옆에 시스템 뒤로가기가 함께 보이지 않는다")
    func swiftUIHostedScreenDoesNotShowSystemBackAlongside() async throws {
        let (sut, _) = makeSUT()
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 402, height: 874))
        window.rootViewController = sut
        window.makeKeyAndVisible()

        let hosting = UIHostingController(rootView: Text("오답노트 상세"))
        sut.pushViewController(hosting, animated: false)
        try await Task.sleep(nanoseconds: 500_000_000)

        #expect(installedBackItem(on: hosting) != nil)
        // UIHostingController는 leftItemsSupplementBackButton을 true로 두어 시스템 뒤로가기를 함께 보여준다.
        #expect(hosting.navigationItem.leftItemsSupplementBackButton == false)
    }

    @Test("SwiftUI 화면이 navigationBarBackButtonHidden(true)를 쓰면 커스텀 뒤로가기가 남지 않는다")
    func swiftUIHiddenBackButtonLeavesNoInstalledItem() async throws {
        let (sut, _) = makeSUT()
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 402, height: 874))
        window.rootViewController = sut
        window.makeKeyAndVisible()

        let hosting = UIHostingController(rootView: Text("결과").navigationBarBackButtonHidden(true))
        sut.pushViewController(hosting, animated: false)
        try await Task.sleep(nanoseconds: 500_000_000)

        #expect(installedBackItem(on: hosting) == nil)
    }
}
