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

    func testTermsAgreementInitialState() async throws {
        let flowVM = SignUpFlowViewModel(signUpService: StubSignUpService())
        let vm = TermsAgreementModalViewModel(signUpFlowViewModel: flowVM, termsService: StubTermsService())
        let vc = TermsAgreementModalViewController(viewModel: vm)

        // `vc.view` forces loadView()/viewDidLoad() synchronously, which calls
        // viewModel.send(.viewDidLoad) and kicks off the unstructured Task that fetches
        // terms from the server. We must await the resulting `.initialTerms` output
        // before snapshotting, otherwise this races the async load (see task-6-report.md
        // fix-round-1 notes).
        let outputs = try await collectAsync(vm.output) { _ = vc.view }
        let hasInitialTerms = outputs.contains {
            if case .initialTerms = $0 { return true }
            return false
        }
        XCTAssertTrue(hasInitialTerms, "expected .initialTerms output before snapshotting")

        assertSnapshot(of: vc, as: .image(on: .iPhone16Pro))
    }

    func testTermsDetailInitialState() {
        let termItem = TermItem(kind: .term(id: 1), title: "이용약관", pdfName: "terms", isAgreed: false)
        let vc = inNav(TermsDetailViewController(viewModel: TermsDetailViewModel(termItem: termItem)))
        assertSnapshot(of: vc, as: .image(on: .iPhone16Pro))
    }
}
