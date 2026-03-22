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

public struct MyPageUserInfo {
    public let name: String
    public let email: String

    public init(name: String, email: String) {
        self.name = name
        self.email = email
    }
}

@MainActor
public func makeMyPageCoordinator(
    userInfo: MyPageUserInfo,
    myPageService: any MyPageService,
    accountRecoveryService: any AccountRecoveryService,
    socialLoginService: any SocialLoginService
) -> any MyPageCoordinator {
    MyPageCoordinatorImpl(
        userInfo: userInfo,
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
