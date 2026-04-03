//
//  AuthSDKConfigurator.swift
//  Auth
//

import KakaoSDKCommon
import KakaoSDKAuth
import GoogleSignIn

/// 소셜 로그인 SDK 초기화 및 URL 핸들링을 담당합니다.
/// AppDelegate / SceneDelegate에서 직접 SDK를 import하지 않도록 래핑합니다.
public struct AuthSDKConfigurator {

    /// KakaoSDK를 초기화합니다. AppDelegate 호출용입니다.
    public static func configure(kakaoAppKey: String) {
        KakaoSDK.initSDK(appKey: kakaoAppKey)
    }

    /// 소셜 로그인 URL 콜백을 처리합니다. SceneDelegate의 openURLContexts  호출용입니다.
    @MainActor @discardableResult
    public static func handleOpenURL(_ url: URL) -> Bool {
        if AuthApi.isKakaoTalkLoginUrl(url) {
            return AuthController.handleOpenUrl(url: url)
        }
        if GIDSignIn.sharedInstance.handle(url) {
            return true
        }
        return false
    }
}
