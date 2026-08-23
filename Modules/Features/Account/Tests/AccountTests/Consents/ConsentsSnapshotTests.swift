//
//  ConsentsSnapshotTests.swift
//  AccountTests
//

import Testing
import SwiftUI
import SnapshotTesting
@testable import Account
import QRIZNetwork

@MainActor
@Suite("Consents 스냅샷 테스트")
struct ConsentsSnapshotTests {
    @Test("재동의+연령확인 모두 필요한 초기 화면")
    func bothRequiredInitialState() async throws {
        let viewModel = ConsentsViewModel(
            termsService: MockTermsService(),
            consentsService: MockConsentsService(),
            myPageService: MockMyPageService(),
            accessTokenProvider: { "token" },
            reAgreementRequired: true,
            ageVerificationRequired: true,
            onComplete: {},
            onAccountDestroyed: {}
        )

        // `ConsentsView`'s `.onAppear` calls `viewModel.onAppear()`, which kicks off an
        // unstructured `Task { await loadTerms() }` fetching from `MockTermsService`.
        // SwiftUI's `.onAppear` timing under `UIHostingController` + a snapshot library is
        // not guaranteed, so we call `onAppear()` directly on the view model here, before
        // constructing the view, and await the load completing — the same pattern already
        // used throughout `ConsentsViewModelTests` — instead of racing SwiftUI's lifecycle
        // the way the Task 6 `TermsAgreementModalViewModel` snapshot test originally did.
        viewModel.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)

        let vc = UIHostingController(rootView: ConsentsView(viewModel: viewModel, onShowTermsDetail: { _ in }))
        assertSnapshot(of: vc, as: .image(on: .iPhone13))
    }
}
