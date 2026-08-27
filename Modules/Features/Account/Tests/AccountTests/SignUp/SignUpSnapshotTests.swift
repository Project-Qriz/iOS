//
//  SignUpSnapshotTests.swift
//  AccountTests
//

import XCTest
import SwiftUI
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
        let vm = TermsAgreementViewModel(
            signUpFlowViewModel: flowVM,
            termsService: StubTermsService(),
            onDismiss: {},
            onTermsAgreed: {}
        )

        // SwiftUI's `.onAppear` timing under `UIHostingController` + a snapshot library is
        // not guaranteed, so we call `onAppear()` directly on the view model here, before
        // constructing the view, and await the load completing (same pattern as
        // ConsentsSnapshotTests) instead of racing SwiftUI's lifecycle.
        vm.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)

        let vc = UIHostingController(rootView: TermsAgreementView(viewModel: vm, onShowTermsDetail: { _ in }))
        assertSnapshot(of: vc, as: .image(on: .iPhone16Pro))
    }

    func testTermsDetailInitialState() {
        let termItem = TermItem(kind: .term(id: 1), title: "이용약관", pdfName: "terms", isAgreed: false)
        let vc = inNav(TermsDetailViewController(viewModel: TermsDetailViewModel(termItem: termItem)))
        assertSnapshot(of: vc, as: .image(on: .iPhone16Pro))
    }
}
