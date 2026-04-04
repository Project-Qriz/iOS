//
//  AppDelegate.swift
//  QRIZ
//
//  Created by ch on 12/10/24.
//

import UIKit
import FirebaseCore
import Auth
import QRIZUtils

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        AnalyticsManager.shared.configure(service: AnalyticsServiceImpl())

        let appKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_NATIVE_APP_KEY") as? String ?? ""
        AuthSDKConfigurator.configure(kakaoAppKey: appKey)
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
