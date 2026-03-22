import UIKit
import QRIZUtils
import Network
import Account

// MARK: - Public (메인 앱에 노출)

@MainActor
public protocol MyPageCoordinator: Coordinator {
    var delegate: MyPageCoordinatorDelegate? { get set }
}

@MainActor
public protocol MyPageCoordinatorDelegate: AnyObject {
    func myPageCoordinatorDidLogout(_ coordinator: any MyPageCoordinator)
    func myPageCoordinatorDidRequestExamScheduleSelection(_ coordinator: any MyPageCoordinator)
}

@MainActor
public func makeMyPageCoordinator(
    myPageService: MyPageService,
    accountRecoveryService: AccountRecoveryService,
    socialLoginService: SocialLoginService
) -> any MyPageCoordinator {
    MyPageCoordinatorImpl(
        myPageService: myPageService,
        accountRecoveryService: accountRecoveryService,
        socialLoginService: socialLoginService
    )
}

// MARK: - Internal (패키지 내부 전용)

@MainActor
protocol MyPageNavigating: MyPageCoordinator {
    func showSettingsView()
    func showFindPassword()
    func showResetAlert(confirm: @escaping () -> Void)
    func showExamSelectionSheet()
    func showTermsDetail(for term: TermItem)
    func showLogoutAlert(confirm: @escaping () -> Void)
    func showDeleteAccount()
    func showConfirmDeleteAlert(confirm: @escaping () -> Void)
}
