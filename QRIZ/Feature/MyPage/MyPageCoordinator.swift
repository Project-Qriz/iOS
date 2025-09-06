//
//  MyPageCoordinator.swift
//  QRIZ
//
//  Created by 김세훈 on 2/25/25.
//

import UIKit

@MainActor
protocol MyPageCoordinator: Coordinator {
    var delegate: MyPageCoordinatorDelegate? { get set }
    func showSettingsView()
//    func showChangePasswordView()
    func showFindPassword()
    func showResetAlert(confirm: @escaping () -> Void)
    func showExamSelectionSheet()
    func showTermsDetail(for term: TermItem)
    func showLogoutAlert(confirm: @escaping () -> Void)
    func showDeleteAccount()
    func showConfirmDeleteAlert(confirm: @escaping () -> Void)
}

@MainActor
protocol MyPageCoordinatorDelegate: AnyObject {
  /// 회원탈퇴 완료 시 호출
  func myPageCoordinatorDidLogout(_ coordinator: MyPageCoordinator)
}

@MainActor
final class MyPageCoordinatorImpl: MyPageCoordinator {
    
    private weak var navigationController: UINavigationController?
    weak var delegate: MyPageCoordinatorDelegate?
    weak var examDelegate: ExamSelectionDelegate?
    private let examService: ExamScheduleService
    private let myPageService: MyPageService
    private let accountRecoveryService: AccountRecoveryService
    private let socialLoginService: SocialLoginService
    var childCoordinators: [Coordinator] = []
    
    init(
        examService: ExamScheduleService,
        myPageService: MyPageService,
        accountRecoveryService: AccountRecoveryService,
        socialLoginService: SocialLoginService
    ) {
        self.examService = examService
        self.myPageService = myPageService
        self.accountRecoveryService = accountRecoveryService
        self.socialLoginService = socialLoginService
    }
    
    func start() -> UIViewController {
        let viewModel = MyPageViewModel(
            userName: UserInfoManager.shared.name,
            myPageService: myPageService
        )
        let myPageVC = MyPageViewController(viewModel: viewModel)
        myPageVC.coordinator = self
        
        let navi = UINavigationController(rootViewController: myPageVC)
        self.navigationController = navi
        return navi
    }
    
    func showSettingsView() {
        let viewModel = SettingsViewModel(
            userName: UserInfoManager.shared.name,
            email: UserInfoManager.shared.email,
            myPageService: myPageService,
            socialLoginService: socialLoginService
        )
        let vc = SettingsViewController(viewModel: viewModel)
        vc.coordinator = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
//    func showChangePasswordView() {
//        let viewModel = ChangePasswordViewModel(myPageService: myPageService)
//        let vc = ChangePasswordViewController(viewModel: viewModel)
//        vc.coordinator = self
//        navigationController?.pushViewController(vc, animated: true)
//    }
    
    func showFindPassword() {
        guard let navi = navigationController else { return }
        let recoveryCoordinator = AccountRecoveryCoordinatorImpl(
            navigationController: navi,
            accountRecoveryService: accountRecoveryService
        )
        recoveryCoordinator.delegate = self
        childCoordinators.append(recoveryCoordinator)
        _ = recoveryCoordinator.start()
    }
    
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
    
    func showExamSelectionSheet() {
        let viewModel = ExamScheduleSelectionViewModel(examScheduleService: examService)
        viewModel.delegate = examDelegate
        let vc = ExamScheduleSelectionViewController(examScheduleSelectionVM: viewModel)
        vc.modalPresentationStyle = .pageSheet
        
        if let sheet = vc.sheetPresentationController {
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
            
            let fit = UISheetPresentationController.Detent.custom(
                identifier: .init("fit")
            ) { context in min(540, context.maximumDetentValue) }
            
            sheet.detents = [fit]
            sheet.selectedDetentIdentifier = .init("fit")
        }
        
        navigationController?.present(vc, animated: true)
    }
    
    func showTermsDetail(for term: TermItem) {
        let viewModel = TermsDetailViewModel(termItem: term)
        let vc = TermsDetailViewController(viewModel: viewModel)
        vc.modalPresentationStyle = .fullScreen
        vc.dismissDelegate = self
        navigationController?.present(vc, animated: true)
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
    
    func showDeleteAccount() {
        let viewModel = DeleteAccountViewModel(myPageService: myPageService)
        let vc = DeleteAccountViewController(viewModel: viewModel)
        vc.coordinator = self
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
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
