//
//  SignUpSnapshotTests.swift
//  AccountTests
//

import XCTest
import SnapshotTesting
@testable import Account

@MainActor
class SignUpSnapshotTests: AccountSnapshotTestCase {

    private var signUpService: StubSignUpService!
    private var flowVM: SignUpFlowViewModel!

    override func setUp() {
        super.setUp()
        signUpService = StubSignUpService()
        flowVM = SignUpFlowViewModel(signUpService: signUpService)
    }

    func testNameInputInitialState() {
        let vc = inNav(NameInputViewController(nameInputVM: NameInputViewModel(signUpFlowViewModel: flowVM)))
        vc.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        vc.view.layoutIfNeeded()
        assertSnapshot(of: vc, as: .image)
    }

    func testIDInputInitialState() {
        let vc = inNav(IDInputViewController(idInputVM: IDInputViewModel(signUpFlowViewModel: flowVM, signUpService: signUpService)))
        vc.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        vc.view.layoutIfNeeded()
        assertSnapshot(of: vc, as: .image)
    }

    func testPasswordInputInitialState() {
        let vc = inNav(PasswordInputViewController(passwordInputVM: PasswordInputViewModel(signUpFlowViewModel: flowVM)))
        vc.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        vc.view.layoutIfNeeded()
        assertSnapshot(of: vc, as: .image)
    }

    func testSignUpVerificationInitialState() {
        let vc = inNav(SignUpVerificationViewController(signUpVerificationVM: SignUpVerificationViewModel(signUpFlowViewModel: flowVM, signUpService: signUpService)))
        vc.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        vc.view.layoutIfNeeded()
        assertSnapshot(of: vc, as: .image)
    }

    func testTermsAgreementInitialState() {
        let vm = TermsAgreementModalViewModel(signUpFlowViewModel: flowVM)
        let vc = TermsAgreementModalViewController(viewModel: vm)
        vc.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        vc.view.layoutIfNeeded()
        assertSnapshot(of: vc, as: .image)
    }

    func testTermsDetailInitialState() {
        let termItem = TermItem(title: "이용약관", pdfName: "terms", isAgreed: false)
        let vc = inNav(TermsDetailViewController(viewModel: TermsDetailViewModel(termItem: termItem)))
        vc.view.frame = CGRect(origin: .zero, size: Self.deviceSize)
        vc.view.layoutIfNeeded()
        assertSnapshot(of: vc, as: .image)
    }
}
