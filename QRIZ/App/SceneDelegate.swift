//
//  SceneDelegate.swift
//  QRIZ
//
//  Created by ch on 12/10/24.
//

import UIKit
import Auth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appCoordinator: (any AppCoordinator)?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)

        let dependency = AppCoordinatorDependencyImpl()
        let appCoordinator = AppCoordinatorImpl(window: window, dependency: dependency)

        self.window = window
        self.appCoordinator = appCoordinator

        window.rootViewController = appCoordinator.start()
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) { }
    func sceneDidBecomeActive(_ scene: UIScene) { }
    func sceneWillResignActive(_ scene: UIScene) { }
    func sceneWillEnterForeground(_ scene: UIScene) { }
    func sceneDidEnterBackground(_ scene: UIScene) { }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        AuthSDKConfigurator.handleOpenURL(url)
    }
}
