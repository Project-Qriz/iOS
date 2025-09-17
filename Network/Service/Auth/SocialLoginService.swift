//
//  SocialLoginService.swift
//  QRIZ
//
//  Created by 김세훈 on 8/18/25.
//

import UIKit
import KakaoSDKAuth
import KakaoSDKUser
import GoogleSignIn

protocol SocialLoginService {
    /// 카카오 로그인
    func loginWithKakao() async throws -> SocialLoginResponse
    
    /// 카카오 로그아웃
    /// https://developers.kakao.com/docs/latest/ko/kakaologin/common#logout
    func logoutKakao() async throws
    
    /// 카카오 로그인 연결 해제
    /// https://developers.kakao.com/docs/latest/ko/kakaologin/rest-api#unlink
    func unlinkKakao() async throws
    
    /// 구글 로그인
    func loginWithGoogle(presenting: UIViewController) async throws -> SocialLoginResponse
}

final class SocialLoginServiceImpl: SocialLoginService {
    
    // MARK: - Properties
    
    private let network: Network
    
    // MARK: - Initialize
    
    init(network: Network = NetworkImpl()) {
        self.network = network
    }
    
    
    // MARK: - Functions
    
    func loginWithKakao() async throws -> SocialLoginResponse {
        let accessToken = try await kakaoAccessToken()
        let request = SocialLoginRequest(provider: .kakao, authCode: accessToken)
        return try await network.send(request)
    }
    
    func logoutKakao() async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            UserApi.shared.logout { error in
                if let error = error {
                    cont.resume(throwing: error)
                } else {
                    cont.resume(returning: ())
                }
            }
        }
    }
    
    func unlinkKakao() async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            UserApi.shared.unlink { error in
                if let error = error {
                    cont.resume(throwing: error)
                } else {
                    cont.resume(returning: ())
                }
            }
        }
    }
    
    // MARK: - Google
    
    func loginWithGoogle(presenting: UIViewController) async throws -> SocialLoginResponse {
        let idToken = try await googleIdToken(presenting: presenting)
        let request = SocialLoginRequest(provider: .google, authCode: idToken)
        return try await network.send(request)
    }
}

private extension SocialLoginServiceImpl {
    func kakaoAccessToken() async throws -> String {
        try await withCheckedThrowingContinuation { cont in
            let complete: (OAuthToken?, Error?) -> Void = { token, error in
                if let error = error {
                    cont.resume(throwing: error)
                    return
                }
                guard let token = token else {
                    cont.resume(throwing: NSError(
                        domain: "kakao",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Empty OAuthToken"]
                    ))
                    return
                }
                cont.resume(returning: token.accessToken)
            }
            
            Task { @MainActor in
                if UserApi.isKakaoTalkLoginAvailable() {
                    UserApi.shared.loginWithKakaoTalk(completion: complete)
                } else {
                    UserApi.shared.loginWithKakaoAccount(completion: complete)
                }
            }
        }
    }
    
    @MainActor
    func googleIdToken(presenting: UIViewController) async throws -> String {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<String, Error>) in
            GIDSignIn.sharedInstance.signIn(withPresenting: presenting) { result, error in
                if let error = error {
                    cont.resume(throwing: error)
                    return
                }
                guard let token = result?.user.idToken?.tokenString, !token.isEmpty else {
                    cont.resume(throwing: NSError(
                        domain: "google",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Empty Google ID Token"]
                    ))
                    return
                }
                cont.resume(returning: token)
            }
        }
    }
}
