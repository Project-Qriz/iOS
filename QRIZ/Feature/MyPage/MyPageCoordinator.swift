//
//  MyPageCoordinator.swift
//  QRIZ
//
//  Created by 김세훈 on 2/25/25.
//

import UIKit

@MainActor
protocol MyPageCoordinator: Coordinator {
    func showTermsDetail(for term: TermItem)
}

@MainActor
final class MyPageCoordinatorImp: MyPageCoordinator {
    
    private weak var navigationController: UINavigationController?
    var childCoordinators: [Coordinator] = []
    
    func start() -> UIViewController {
        let viewModel = MyPageViewModel(userName: UserInfoManager.shared.name)
        let myPageVC = MyPageViewController(viewModel: viewModel)
        myPageVC.coordinator = self
        
        let navi = UINavigationController(rootViewController: myPageVC)
        self.navigationController = navi
        return navi
    }
    
    func showTermsDetail(for term: TermItem) {
        let viewModel = TermsDetailViewModel(termItem: term)
        let vc = TermsDetailViewController(viewModel: viewModel)
        vc.modalPresentationStyle = .fullScreen
        vc.dismissDelegate = self
        navigationController?.present(vc, animated: true)
    }
}

// MARK: - TermsDetailDismissible

extension MyPageCoordinatorImp: TermsDetailDismissible {
    func dismissTermsDetail() {
        navigationController?.dismiss(animated: true)
    }
}
