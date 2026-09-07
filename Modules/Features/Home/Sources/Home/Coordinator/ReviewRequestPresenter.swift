import UIKit
import SwiftUI
import QRIZUtils

/// 리뷰 요청 팝업을 홈 화면 위에 모달로 띄우기 위한 진입점.
@MainActor
final class ReviewRequestPresenter {

    private static let appStoreReviewURL = URL(string: "https://apps.apple.com/app/id6755752454?action=write-review")!

    private let reviewPromptService: any ReviewPromptService
    private let openURL: (URL) -> Void
    private weak var presentedViewController: UIViewController?

    private var onDismissed: (() -> Void)?

    init(
        reviewPromptService: any ReviewPromptService,
        openURL: @escaping (URL) -> Void = { UIApplication.shared.open($0) }
    ) {
        self.reviewPromptService = reviewPromptService
        self.openURL = openURL
    }

    /// - Parameter onDismissed: 팝업이 닫힌 뒤 호출된다. 호출자가 이 프레젠터에 대한
    ///   강한 참조를 해제할 수 있는 시점을 알리기 위함(팝업이 떠 있는 동안은 호출자가
    ///   프레젠터를 강하게 들고 있어야 한다 — 그렇지 않으면 버튼 탭 클로저가 캡처한
    ///   self가 조기에 해제될 수 있다).
    func makeViewController(onDismissed: @escaping () -> Void) -> UIViewController {
        self.onDismissed = onDismissed
        let view = ReviewRequestPopupView(
            onPostpone: { [weak self] in self?.postpone() },
            onReview: { [weak self] in self?.review() }
        )
        let hostingController = UIHostingController(rootView: view)
        hostingController.modalPresentationStyle = .overFullScreen
        hostingController.modalTransitionStyle = .crossDissolve
        hostingController.view.backgroundColor = .clear
        self.presentedViewController = hostingController
        return hostingController
    }

    func postpone() {
        reviewPromptService.postponePrompt()
        dismiss()
    }

    func review() {
        reviewPromptService.markReviewed()
        openURL(Self.appStoreReviewURL)
        dismiss()
    }

    private func dismiss() {
        presentedViewController?.dismiss(animated: true) { [onDismissed] in onDismissed?() }
    }
}
