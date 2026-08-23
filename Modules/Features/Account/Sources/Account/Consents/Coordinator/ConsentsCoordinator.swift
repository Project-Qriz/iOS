import UIKit
import SwiftUI
import QRIZNetwork
import QRIZUtils

@MainActor
public protocol ConsentsCoordinator: Coordinator {
    var delegate: ConsentsCoordinatorDelegate? { get set }
}

@MainActor
public protocol ConsentsCoordinatorDelegate: AnyObject {
    func didCompleteConsents(_ coordinator: ConsentsCoordinator)
    /// 연령 미충족 확정으로 계정이 파기된 경우 — 로그아웃 처리 필요
    func didDenyAgeConsents(_ coordinator: ConsentsCoordinator)
}

@MainActor
public final class ConsentsCoordinatorImpl: ConsentsCoordinator {

    public weak var delegate: ConsentsCoordinatorDelegate?
    private let navigationController: UINavigationController
    private var viewModel: ConsentsViewModel?

    public init(
        navigationController: UINavigationController,
        termsService: TermsService,
        consentsService: ConsentsService,
        myPageService: MyPageService,
        accessTokenProvider: @escaping () -> String?,
        reAgreementRequired: Bool,
        ageVerificationRequired: Bool
    ) {
        self.navigationController = navigationController
        let vm = ConsentsViewModel(
            termsService: termsService,
            consentsService: consentsService,
            myPageService: myPageService,
            accessTokenProvider: accessTokenProvider,
            reAgreementRequired: reAgreementRequired,
            ageVerificationRequired: ageVerificationRequired,
            onComplete: { [weak self] in
                guard let self else { return }
                self.delegate?.didCompleteConsents(self)
            },
            onAccountDestroyed: { [weak self] in
                guard let self else { return }
                self.delegate?.didDenyAgeConsents(self)
            }
        )
        self.viewModel = vm
    }

    public func start() -> UIViewController {
        guard let viewModel else { fatalError("ConsentsViewModel not initialized") }
        let view = ConsentsView(
            viewModel: viewModel,
            onShowTermsDetail: { [weak self] term in self?.showTermsDetail(for: term) }
        )
        let hostingController = UIHostingController(rootView: view)
        navigationController.viewControllers = [hostingController]
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.modalPresentationStyle = .fullScreen
        return navigationController
    }

    private func showTermsDetail(for term: TermItem) {
        let detailViewModel = TermsDetailViewModel(termItem: term)
        let vc = TermsDetailViewController(viewModel: detailViewModel)
        vc.modalPresentationStyle = .fullScreen
        navigationController.present(vc, animated: true)
    }
}
