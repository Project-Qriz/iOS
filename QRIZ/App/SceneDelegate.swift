//
//  SceneDelegate.swift
//  QRIZ
//
//  Created by ch on 12/10/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var appCoordinator: AppCoordinatorImp?
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
        let dependency = AppCoordinatorDependencyImp()
        let appCoordinator = AppCoordinatorImp(window: window, dependency: dependency)
        
        self.window = window
        window.rootViewController = UINavigationController(rootViewController: DailyResultViewController(viewModel: DailyResultViewModel(dailyTestType: .weekly)))
        window.makeKeyAndVisible()
//        self.appCoordinator = appCoordinator
//        
//        _ = appCoordinator.start()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) { }
    func sceneDidBecomeActive(_ scene: UIScene) { }
    func sceneWillResignActive(_ scene: UIScene) { }
    func sceneWillEnterForeground(_ scene: UIScene) { }
    func sceneDidEnterBackground(_ scene: UIScene) { }
}

