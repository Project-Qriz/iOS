//
//  LoginSnapshotTests.swift
//  AccountTests
//

import XCTest
import SnapshotTesting
@testable import Account

@MainActor
class LoginSnapshotTests: AccountSnapshotTestCase {

    func testInitialState() {
        let vm = LoginViewModel(
            loginService: StubLoginService(),
            userInfoService: StubUserInfoService(),
            socialLoginService: StubSocialLoginService()
        )
        let vc = LoginViewController(loginVM: vm)
        vc.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        vc.view.layoutIfNeeded()

        assertSnapshot(of: vc, as: .image)
    }
}
