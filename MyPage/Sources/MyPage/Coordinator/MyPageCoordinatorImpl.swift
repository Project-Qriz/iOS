import UIKit
import DesignSystem
import QRIZUtils
import Network
import Account

@MainActor
final class MyPageCoordinatorImpl: MyPageNavigating, NavigationGuard {

    // MARK: - Properties

    private let userInfo: MyPageUserInfo
    private weak var navigationController: UINavigationController?
    weak var delegate: MyPageCoordinatorDelegate?
    private let myPageService: any MyPageService
    private let accountRecoveryService: any AccountRecoveryService
    private let socialLoginService: any SocialLoginService
    var childCoordinators: [Coordinator] = []

    // NavigationGuard
    var isNavigating: Bool = false

    // MARK: - Initialize

    init(
        userInfo: MyPageUserInfo,
        myPageService: any MyPageService,
        accountRecoveryService: any AccountRecoveryService,
        socialLoginService: any SocialLoginService
    ) {
        self.userInfo = userInfo
        self.myPageService = myPageService
        self.accountRecoveryService = accountRecoveryService
        self.socialLoginService = socialLoginService
    }

    // MARK: - Start

    func start() -> UIViewController {
        let viewModel = MyPageViewModel(
            userName: userInfo.name,
            myPageService: myPageService
        )
        let myPageVC = MyPageViewController(viewModel: viewModel)
        myPageVC.coordinator = self

        let navi = UINavigationController(rootViewController: myPageVC)
        self.navigationController = navi
        return navi
    }

    func showSettingsView() {
        guardNavigation {
            let viewModel = SettingsViewModel(
                userName: userInfo.name,
                email: userInfo.email,
                provider: userInfo.provider,
                myPageService: myPageService,
                socialLoginService: socialLoginService
            )
            let vc = SettingsViewController(viewModel: viewModel)
            vc.coordinator = self
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    func showFindPassword() {
        guardNavigation {
            guard let navi = self.navigationController else { return }
            let recoveryCoordinator = AccountRecoveryCoordinatorImpl(
                navigationController: navi,
                accountRecoveryService: accountRecoveryService
            )
            recoveryCoordinator.delegate = self
            childCoordinators.append(recoveryCoordinator)
            _ = recoveryCoordinator.start()
        }
    }

    func requestExamScheduleSelection() {
        guardNavigation {
            self.delegate?.myPageCoordinatorDidRequestExamScheduleSelection(self)
        }
    }

    func showTermsDetail(for term: TermItem) {
        guardNavigation {
            let viewModel = TermsDetailViewModel(termItem: term)
            let vc = TermsDetailViewController(viewModel: viewModel)
            vc.modalPresentationStyle = .fullScreen
            vc.dismissDelegate = self
            navigationController?.present(vc, animated: true)
        }
    }

    func showDeleteAccount() {
        guardNavigation {
            let viewModel = DeleteAccountViewModel(
                provider: userInfo.provider,
                myPageService: myPageService,
                socialLoginService: socialLoginService
            )
            let vc = DeleteAccountViewController(viewModel: viewModel)
            vc.coordinator = self
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    // MARK: - Alerts

    func showResetAlert(confirm: @escaping () -> Void) {
        let alert = TwoButtonCustomAlertViewController(
            title: "플랜을 초기화 할까요?",
            description: "지금까지의 플랜이 초기화되며,\nDay1부터 다시 시작됩니다.",
            confirmAction: UIAction { [weak self] _ in
                confirm()
                self?.navigationController?.dismiss(animated: true)
            },
            cancelAction: UIAction { [weak self] _ in
                self?.navigationController?.dismiss(animated: true)
            }
        )
        navigationController?.present(alert, animated: true)
    }

    func showLogoutAlert(confirm: @escaping () -> Void) {
        let alert = TwoButtonCustomAlertViewController(
            title: "로그아웃",
            description: "로그아웃 하시겠습니까?",
            confirmAction: UIAction { [weak self] _ in
                confirm()
                self?.navigationController?.dismiss(animated: true)
            },
            cancelAction: UIAction { [weak self] _ in
                self?.navigationController?.dismiss(animated: true)
            }
        )
        navigationController?.present(alert, animated: true)
    }

    func showConfirmDeleteAlert(confirm: @escaping () -> Void) {
        let alert = TwoButtonCustomAlertViewController(
            title: "회원탈퇴",
            description: "탈퇴 시 사용자와 관련된 모든 데이터는 즉시\n삭제되며, 복구가 불가능합니다.\n\n정말로 탈퇴하시겠어요?",
            descriptionLine: 4,
            confirmTitle: "탈퇴하기",
            cancelTitle: "더 써볼래요",
            confirmAction: UIAction { [weak self] _ in
                confirm()
                self?.navigationController?.dismiss(animated: true)
            },
            cancelAction: UIAction { [weak self] _ in
                self?.navigationController?.dismiss(animated: true)
            }
        )
        navigationController?.present(alert, animated: true)
    }

    // MARK: - Session

    func handleLogoutSucceeded() {
        delegate?.myPageCoordinatorDidLogout(self)
    }

    func handleDeletionSucceeded() {
        delegate?.myPageCoordinatorDidLogout(self)
    }
}

// MARK: - TermsDetailDismissible

extension MyPageCoordinatorImpl: TermsDetailDismissible {
    func dismissTermsDetail() {
        navigationController?.dismiss(animated: true)
    }
}

// MARK: - AccountRecoveryCoordinatorDelegate

extension MyPageCoordinatorImpl: AccountRecoveryCoordinatorDelegate {
    func didFinishPasswordReset(_ coordinator: AccountRecoveryCoordinator) {
        childCoordinators.removeAll { $0 === coordinator }
        navigationController?.popToRootViewController(animated: true)
    }
}
