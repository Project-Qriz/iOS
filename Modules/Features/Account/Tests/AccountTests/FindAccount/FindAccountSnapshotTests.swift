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
        assertSnapshot(of: vc, as: .image(on: .iPhone16Pro))
    }

    func testFindPasswordVerificationInitialState() {
        let recoveryService = StubAccountRecoveryService()
        let vc = inNav(FindPasswordVerificationViewController(findPasswordVerificationVM: FindPasswordVerificationViewModel(accountRecoveryService: recoveryService)))
        assertSnapshot(of: vc, as: .image(on: .iPhone16Pro))
    }

    func testResetPasswordInitialState() {
        let recoveryService = StubAccountRecoveryService()
        let vc = inNav(ResetPasswordViewController(resetPasswordVM: ResetPasswordViewModel(accountRecoveryService: recoveryService)))
        assertSnapshot(of: vc, as: .image(on: .iPhone16Pro))
    }
}
