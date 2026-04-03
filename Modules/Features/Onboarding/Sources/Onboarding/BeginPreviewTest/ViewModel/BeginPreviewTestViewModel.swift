import Foundation

@MainActor
final class BeginPreviewTestViewModel: ObservableObject {

    // MARK: - Properties

    private let onNavigate: () -> Void

    // MARK: - Initializer

    init(onNavigate: @escaping () -> Void) {
        self.onNavigate = onNavigate
    }

    // MARK: - Methods

    func didTapButton() {
        onNavigate()
    }
}
