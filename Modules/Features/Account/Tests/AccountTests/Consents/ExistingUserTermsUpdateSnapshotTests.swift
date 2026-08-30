import Testing
import SwiftUI
import SnapshotTesting
@testable import Account
import QRIZNetwork

@MainActor
@Suite("ExistingUserTermsUpdate 스냅샷 테스트")
struct ExistingUserTermsUpdateSnapshotTests {
    @Test("초기 화면 (둘 다 미체크)")
    func initialState() async throws {
        let viewModel = ExistingUserTermsUpdateViewModel(
            termsService: MockTermsService(),
            consentsService: MockConsentsService(),
            accessTokenProvider: { "token" },
            onComplete: {}
        )

        viewModel.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)

        let vc = UIHostingController(rootView: ExistingUserTermsUpdateView(viewModel: viewModel, onShowTermsDetail: { _ in }))
        assertSnapshot(of: vc, as: .image(on: .iPhone13))
    }
}
