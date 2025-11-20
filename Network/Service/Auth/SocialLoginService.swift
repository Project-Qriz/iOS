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
import AuthenticationServices

struct AppleLoginResult {
    let serverAuthCode: String // authorizationCode
    let identityToken: String? // id_token
    let name: String?
    let email: String?
}

protocol SocialLoginService {
    /// 카카오 로그인
    func loginWithKakao() async throws -> SocialLoginResponse
    
    /// 카카오 로그아웃
    /// https://developers.kakao.com/docs/latest/ko/kakaologin/common#logout
    func logoutKakao() async throws -> SocialLogoutResponse
    
    /// 카카오 로그인 연결 해제
    /// https://developers.kakao.com/docs/latest/ko/kakaologin/rest-api#unlink
    func unlinkKakao() async throws
    
    /// 구글 로그인
    func loginWithGoogle(presenting: UIViewController) async throws -> SocialLoginResponse
    
    /// 구글 로그아웃
    func logoutGoogle() async throws -> SocialLogoutResponse
    
    /// 애플 로그인
    func loginWithApple(presenting: UIViewController) async throws -> SocialLoginResponse
}

final class SocialLoginServiceImpl: NSObject, SocialLoginService {
    
    // MARK: - Properties
    
    private let network: Network
    private let keychain: KeychainManager
    private var continuation: CheckedContinuation<AppleLoginResult, Error>?
    
    // MARK: Initialize
    
    init(
        network: Network  = NetworkImpl(session: .shared),
        keychain: KeychainManager = KeychainManagerImpl()
    ) {
        self.network  = network
        self.keychain = keychain
    }
    
    
    // MARK: - Functions
    
    func loginWithKakao() async throws -> SocialLoginResponse {
        let accessToken = try await kakaoAccessToken()
        let request = SocialLoginRequest(provider: .kakao, token: accessToken)
        return try await network.send(request)
    }
    
    func logoutKakao() async throws -> SocialLogoutResponse {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            UserApi.shared.logout { error in
                if let error = error {
                    cont.resume(throwing: error)
                } else {
                    cont.resume(returning: ())
                }
            }
        }
        
        let access = keychain.retrieveToken(forKey: HTTPHeaderField.accessToken.rawValue) ?? ""
        let request = SocialLogoutRequest(accessToken: access)
        return try await network.send(request) as SocialLogoutResponse
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
    
    @MainActor
    func ensureGoogleConfigured() async throws {
        guard let iosClientID = Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String,
              let webClientID = Bundle.main.object(forInfoDictionaryKey: "GoogleWebClientID") as? String else {
            throw NSError(
                domain: "google",
                code: -99,
                userInfo: [NSLocalizedDescriptionKey: "Missing GIDClientID or GoogleWebClientID in Info.plist"]
            )
        }
        let config = GIDConfiguration(clientID: iosClientID, serverClientID: webClientID)
        GIDSignIn.sharedInstance.configuration = config
    }
    
    func loginWithGoogle(presenting: UIViewController) async throws -> SocialLoginResponse {
        try await ensureGoogleConfigured()
        let serverAuthCode = try await googleToken(presenting: presenting)
        let request = SocialLoginRequest(provider: .google, token: serverAuthCode)
        return try await network.send(request)
    }
    
    func logoutGoogle() async throws -> SocialLogoutResponse {
        GIDSignIn.sharedInstance.signOut()
        
        let access = keychain.retrieveToken(forKey: HTTPHeaderField.accessToken.rawValue) ?? ""
        let request = SocialLogoutRequest(accessToken: access)
        return try await network.send(request)
    }
    
    // MARK: - Apple
    
    func loginWithApple(presenting: UIViewController) async throws -> SocialLoginResponse {
        let apple = try await performAppleLogin(presenting: presenting)
        let request = SocialLoginRequest(
            provider: .apple,
            serverAuthCode: apple.serverAuthCode,
            idToken: apple.identityToken,
            name: apple.name,
            email: apple.email
        )
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
    func googleToken(presenting: UIViewController) async throws -> String {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<String, Error>) in
            GIDSignIn.sharedInstance.signIn(withPresenting: presenting) { result, error in
                if let error = error {
                    cont.resume(throwing: error)
                    return
                }
                guard let authCode = result?.serverAuthCode, !authCode.isEmpty else {
                    cont.resume(throwing: NSError(
                        domain: "google",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Empty Google ID Token"]
                    ))
                    return
                }
                cont.resume(returning: authCode)
            }
        }
    }
    
    func performAppleLogin(presenting: UIViewController) async throws -> AppleLoginResult {
        return try await withCheckedThrowingContinuation { continuation in
            guard self.continuation == nil else {
                continuation.resume(throwing: NSError(domain: "AlreadyRunning", code: -1))
                return
            }
            
            self.continuation = continuation
            
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension SocialLoginServiceImpl: ASAuthorizationControllerDelegate {
    
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        
        defer { continuation = nil }
        
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            continuation?.resume(throwing: NSError(domain: "InvalidCredential", code: -1))
            return
        }
        
        guard let authCodeData = credential.authorizationCode,
              let authCode = String(data: authCodeData, encoding: .utf8)
        else {
            continuation?.resume(throwing: NSError(domain: "MissingAuthCode", code: -1))
            return
        }
        
        let token: String? = {
            guard let tokenData = credential.identityToken else { return nil }
            return String(data: tokenData, encoding: .utf8)
        }()
        
        let result = AppleLoginResult(
            serverAuthCode: authCode,
            identityToken: token,
            name: credential.fullName?.givenName,
            email: credential.email
        )
        
        continuation?.resume(returning: result)
    }
    
    
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension SocialLoginServiceImpl: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.windows.first }
            .first ?? ASPresentationAnchor()
    }
}
