//
//  SignUpSnapshotTests.swift
//  AccountTests
//

import XCTest
import SnapshotTesting
@testable import Account

@MainActor
class SignUpSnapshotTests: AccountSnapshotTestCase {

    func testNameInputInitialState() {
        let signUpService = StubSignUpService()
        let flowVM = SignUpFlowViewModel(signUpService: signUpService)
        let vc = inNav(NameInputViewController(nameInputVM: NameInputViewModel(signUpFlowViewModel: flowVM)))
        assertSnapshot(of: vc, as: .image(on: .iPhone16Pro))
    }

    func testIDInputInitialState() {
        let signUpService = StubSignUpService()
        let flowVM = SignUpFlowViewModel(signUpService: signUpService)
        let vc = inNav(IDInputViewController(idInputVM: IDInputViewModel(signUpFlowViewModel: flowVM, signUpService: signUpService)))
        assertSnapshot(of: vc, as: .image(on: .iPhone16Pro))
    }

    func testPasswordInputInitialState() {
        let signUpService = StubSignUpService()
        let flowVM = SignUpFlowViewModel(signUpService: signUpService)
        let vc = inNav(PasswordInputViewController(passwordInputVM: PasswordInputViewModel(signUpFlowViewModel: flowVM)))
        assertSnapshot(of: vc, as: .image(on: .iPhone16Pro))
    }

    func testSignUpVerificationInitialState() {
        let signUpService = StubSignUpService()
        let flowVM = SignUpFlowViewModel(signUpService: signUpService)
        let vc = inNav(SignUpVerificationViewController(signUpVerificationVM: SignUpVerificationViewModel(signUpFlowViewModel: flowVM, signUpService: signUpService)))
        assertSnapshot(of: vc, as: .image(on: .iPhone16Pro))
    }

    func testTermsAgreementInitialState() {
        let flowVM = SignUpFlowViewModel(signUpService: StubSignUpService())
        let vm = TermsAgreementModalViewModel(signUpFlowViewModel: flowVM)
        let vc = TermsAgreementModalViewController(viewModel: vm)
        assertSnapshot(of: vc, as: .image(on: .iPhone16Pro))
    }

    func testTermsDetailInitialState() {
        let termItem = TermItem(title: "이용약관", pdfName: "terms", isAgreed: false)
        let vc = inNav(TermsDetailViewController(viewModel: TermsDetailViewModel(termItem: termItem)))
        assertSnapshot(of: vc, as: .image(on: .iPhone16Pro))
    }
}
