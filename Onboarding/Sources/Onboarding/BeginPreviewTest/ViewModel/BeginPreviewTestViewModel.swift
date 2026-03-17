import Foundation

@MainActor
final class BeginPreviewTestViewModel: ObservableObject {
    var onNavigate: (() -> Void)?

    func didTapButton() {
        onNavigate?()
    }
}
