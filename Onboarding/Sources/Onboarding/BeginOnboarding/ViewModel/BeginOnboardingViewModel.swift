import Foundation

@MainActor
final class BeginOnboardingViewModel: ObservableObject {
    var onNavigate: (() -> Void)?

    func didTapButton() {
        onNavigate?()
    }
}
