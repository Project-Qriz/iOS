import UIKit
import SwiftUI
import QRIZNetwork

/// 기존 가입자 약관 업데이트 팝업을 홈 화면 위에 모달로 띄우기 위한 진입점.
///
/// 다른 화면과 달리 별도 네비게이션 흐름이 없는 단발성 팝업이라
/// delegate 프로토콜을 두는 대신 `onComplete` 클로저 하나로 완료를 알린다.
@MainActor
public final class ExistingUserTermsUpdatePresenter {

    private weak var presentedViewController: UIViewController?
    private let termsService: TermsService
    private let consentsService: ConsentsService
    private let accessTokenProvider: () -> String?

    public init(
        termsService: TermsService,
        consentsService: ConsentsService,
        accessTokenProvider: @escaping () -> String?
    ) {
        self.termsService = termsService
        self.consentsService = consentsService
        self.accessTokenProvider = accessTokenProvider
    }

    /// dim 배경 위 팝업 카드를 담은 `UIViewController`를 반환한다. 호출자가 `present(_:animated:)`로 띄운다.
    public func makeViewController(onComplete: @escaping () -> Void) -> UIViewController {
        let viewModel = ExistingUserTermsUpdateViewModel(
            termsService: termsService,
            consentsService: consentsService,
            accessTokenProvider: accessTokenProvider,
            onComplete: onComplete
        )
        let view = ExistingUserTermsUpdateView(
            viewModel: viewModel,
            onShowTermsDetail: { [weak self] term in self?.showTermsDetail(for: term) }
        )
        let hostingController = UIHostingController(rootView: view)
        hostingController.modalPresentationStyle = .overFullScreen
        hostingController.modalTransitionStyle = .coverVertical
        hostingController.view.backgroundColor = .clear
        self.presentedViewController = hostingController
        return hostingController
    }

    private func showTermsDetail(for term: TermItem) {
        let detailViewModel = TermsDetailViewModel(termItem: term)
        let vc = TermsDetailViewController(viewModel: detailViewModel)
        vc.dismissDelegate = self
        vc.modalPresentationStyle = .fullScreen
        presentedViewController?.present(vc, animated: true)
    }
}

// MARK: - TermsDetailDismissible

extension ExistingUserTermsUpdatePresenter: TermsDetailDismissible {
    public func dismissTermsDetail() {
        presentedViewController?.dismiss(animated: true)
    }
}
