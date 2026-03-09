//
//  FindAccountSnapshotTests.swift
//  AccountTests
//

import XCTest
import SnapshotTesting
@testable import Account

@MainActor
class FindAccountSnapshotTests: AccountSnapshotTestCase {

    func testFindIDInitialState() {
        let recoveryService = StubAccountRecoveryService()
        let vc = inNav(FindIDViewController(findIDInputVM: FindIDViewModel(accountRecoveryService: recoveryService)))
        vc.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        vc.view.layoutIfNeeded()
        assertSnapshot(of: vc, as: .image)
    }

    func testFindPasswordVerificationInitialState() {
        let recoveryService = StubAccountRecoveryService()
        let vc = inNav(FindPasswordVerificationViewController(findPasswordVerificationVM: FindPasswordVerificationViewModel(accountRecoveryService: recoveryService)))
        vc.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        vc.view.layoutIfNeeded()
        assertSnapshot(of: vc, as: .image)
    }

    func testResetPasswordInitialState() {
        let recoveryService = StubAccountRecoveryService()
        let vc = inNav(ResetPasswordViewController(resetPasswordVM: ResetPasswordViewModel(accountRecoveryService: recoveryService)))
        vc.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        vc.view.layoutIfNeeded()
        assertSnapshot(of: vc, as: .image)
    }
}
