import Foundation

@MainActor
final class BeginOnboardingViewModel: ObservableObject {

    // MARK: - Properties

    private let onNavigate: () -> Void

    // MARK: - Initialization

    init(onNavigate: @escaping () -> Void) {
        self.onNavigate = onNavigate
    }

    // MARK: - Methods

    func didTapButton() {
        onNavigate()
    }
}
