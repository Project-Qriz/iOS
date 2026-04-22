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
            socialLoginService: StubSocialLoginService(),
            userInfo: .shared
        )
        let vc = LoginViewController(loginVM: vm)
        assertSnapshot(of: vc, as: .image(on: .iPhone16Pro))
    }
}
