//
//  FindAccountSnapshotTests.swift
//  AccountTests
//

import XCTest
import SnapshotTesting
@testable import Account

@MainActor
class FindAccountSnapshotTests: AccountSnapshotTestCase {

    private var recoveryService: StubAccountRecoveryService!

    override func setUp() {
        super.setUp()
        recoveryService = StubAccountRecoveryService()
    }

    override func tearDown() {
        recoveryService = nil
        super.tearDown()
    }

    func testFindIDInitialState() {
        let vc = inNav(FindIDViewController(findIDInputVM: FindIDViewModel(accountRecoveryService: recoveryService)))
        vc.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        vc.view.layoutIfNeeded()
        assertSnapshot(of: vc, as: .image)
    }

    func testFindPasswordVerificationInitialState() {
        let vc = inNav(FindPasswordVerificationViewController(findPasswordVerificationVM: FindPasswordVerificationViewModel(accountRecoveryService: recoveryService)))
        vc.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        vc.view.layoutIfNeeded()
        assertSnapshot(of: vc, as: .image)
    }

    func testResetPasswordInitialState() {
        let vc = inNav(ResetPasswordViewController(resetPasswordVM: ResetPasswordViewModel(accountRecoveryService: recoveryService)))
        vc.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        vc.view.layoutIfNeeded()
        assertSnapshot(of: vc, as: .image)
    }
}
