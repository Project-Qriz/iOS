import XCTest
import SnapshotTesting
@testable import MyPage

@MainActor
class DeleteAccountSnapshotTests: MyPageSnapshotTestCase {

    // MARK: - ViewController

    func testInitialState() {
        let vm = DeleteAccountViewModel(
            provider: "kakao",
            myPageService: MockMyPageService(),
            socialLoginService: MockSocialLoginService()
        )
        let vc = DeleteAccountViewController(viewModel: vm)
        let nav = inNav(vc)
        nav.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        nav.view.layoutIfNeeded()
        assertSnapshot(of: nav, as: .image)
    }

    // MARK: - 뷰 컴포넌트

    func testDeleteAccountInfoView() {
        let view = DeleteAccountInfoView()
        assertSnapshot(of: snapshotView(view), as: .image)
    }
}
