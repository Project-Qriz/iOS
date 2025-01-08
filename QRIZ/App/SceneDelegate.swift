//
//  SceneDelegate.swift
//  QRIZ
//
//  Created by ch on 12/10/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        UINavigationBar.configureNavigationBackButton()
        let name = NameInputViewController(nameInputVM: NameInputViewModel())
        let email = EmailInputViewController()
        let code = VerificationCodeViewController()
        let id = IdInputViewController()
        let password = PasswordInputViewController()
        
        let navi = UINavigationController(rootViewController: password)
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navi
        window?.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) { }
    func sceneDidBecomeActive(_ scene: UIScene) { }
    func sceneWillResignActive(_ scene: UIScene) { }
    func sceneWillEnterForeground(_ scene: UIScene) { }
    func sceneDidEnterBackground(_ scene: UIScene) { }
}

