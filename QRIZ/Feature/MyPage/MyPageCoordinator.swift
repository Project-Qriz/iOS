//
//  MyPageCoordinator.swift
//  QRIZ
//
//  Created by 김세훈 on 2/25/25.
//

import UIKit

@MainActor
protocol MyPageCoordinator: Coordinator {
}

@MainActor
final class MyPageCoordinatorImp: MyPageCoordinator {
    
    var childCoordinators: [Coordinator] = []
    
    func start() -> UIViewController {
        let viewModel = MyPageViewModel(userName: UserInfoManager.shared.name)
        let myPageVC = MyPageViewController(viewModel: viewModel)
        let navi = UINavigationController(rootViewController: myPageVC)
        return navi
    }
}
