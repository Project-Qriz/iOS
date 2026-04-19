//
//  AppDelegate.swift
//  QRIZ
//
//  Created by ch on 12/10/24.
//

import UIKit
import FirebaseCore
import GoogleMobileAds
import AppTrackingTransparency
import Auth
import QRIZUtils

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        MobileAds.shared.start()
        AnalyticsManager.shared.configure(service: AnalyticsServiceImpl())
        requestTrackingAuthorization()

        let appKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_NATIVE_APP_KEY") as? String ?? ""
        AuthSDKConfigurator.configure(kakaoAppKey: appKey)
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    private func requestTrackingAuthorization() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { _ in })
        }
    }
}
