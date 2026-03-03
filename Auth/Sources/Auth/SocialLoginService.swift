//
//  SocialLoginService.swift
//  Auth
//

import UIKit
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser
import GoogleSignIn
import AuthenticationServices
import QRIZUtils
import Network

public protocol SocialLoginService: Sendable {
    func loginWithKakao() async throws -> SocialLoginResponse
    func logoutKakao() async throws
    func unlinkKakao() async throws

    func loginWithGoogle(presenting: UIViewController) async throws -> SocialLoginResponse
    func logoutGoogle() async throws

    func loginWithApple(presenting: UIViewController) async throws -> SocialLoginResponse
    func logoutApple() async throws
}

@MainActor
public final class SocialLoginServiceImpl: NSObject, SocialLoginService {

    // MARK: - Properties
    private let network: Network
    private let keychain: KeychainManager
    private var continuation: CheckedContinuation<AppleLoginResult, Error>?

    // MARK: - Initialize
    public init(
        network: Network = NetworkImpl(session: .shared),
        keychain: KeychainManager = KeychainManagerImpl()
    ) {
        self.network = network
        self.keychain = keychain
    }

    // MARK: - Kakao

    public func loginWithKakao() async throws -> SocialLoginResponse {
        try await performLogin {
            let token = try await self.kakaoAccessToken()
            return SocialLoginRequest(provider: .kakao, token: token)
        }
    }

    public func logoutKakao() async throws {
        try await kakaoVoidCallback { UserApi.shared.logout(completion: $0) }
        try await serverLogout()
    }

    public func unlinkKakao() async throws {
        try await kakaoVoidCallback { UserApi.shared.unlink(completion: $0) }
    }

    // MARK: - Google

    public func loginWithGoogle(presenting: UIViewController) async throws -> SocialLoginResponse {
        try await performLogin {
            try await self.ensureGoogleConfigured()
            let code = try await self.googleToken(presenting: presenting)
            return SocialLoginRequest(provider: .google, token: code)
        }
    }

    public func logoutGoogle() async throws {
        GIDSignIn.sharedInstance.signOut()
        try await serverLogout()
    }

    // MARK: - Apple

    public func loginWithApple(presenting: UIViewController) async throws -> SocialLoginResponse {
        try await performLogin {
            let apple = try await self.performAppleLogin(presenting: presenting)
            return SocialLoginRequest(
                provider: .apple,
                serverAuthCode: apple.serverAuthCode,
                idToken: apple.identityToken,
                name: apple.name,
                email: apple.email
            )
        }
    }

    public func logoutApple() async throws {
        try await serverLogout()
    }
}

// MARK: - Private Helpers

private extension SocialLoginServiceImpl {

    /// 로그인 요청 빌드 → 전송 → 에러 매핑을 한 곳에서 처리
    func performLogin(_ buildRequest: () async throws -> SocialLoginRequest) async throws -> SocialLoginResponse {
        do {
            return try await network.send(buildRequest())
        } catch {
            throw mappedError(error)
        }
    }

    /// 서버 로그아웃 요청 (Kakao / Google / Apple 공통)
    func serverLogout() async throws {
        let accessToken = keychain.retrieveToken(forKey: TokenKey.accessToken.rawValue) ?? ""
        _ = try await network.send(SocialLogoutRequest(accessToken: accessToken))
    }

    /// Kakao SDK completion handler → async/throws 변환
    func kakaoVoidCallback(_ call: @escaping (@escaping (Error?) -> Void) -> Void) async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            call { error in
                if let error { cont.resume(throwing: error) }
                else { cont.resume(returning: ()) }
            }
        }
    }

    /// SDK별 취소 에러를 SocialAuthError.cancelled로 변환
    func mappedError(_ error: Error) -> Error {
        if let sdkError = error as? KakaoSDKCommon.SdkError,
           case .ClientFailed(let reason, _) = sdkError,
           reason == .Cancelled {
            return SocialAuthError.cancelled
        }
        if let nsError = error as NSError?,
           nsError.domain == "com.google.GIDSignIn",
           nsError.code == -5 {
            return SocialAuthError.cancelled
        }
        if let appleError = error as? ASAuthorizationError,
           appleError.code == .canceled {
            return SocialAuthError.cancelled
        }
        return error
    }

    func kakaoAccessToken() async throws -> String {
        try await withCheckedThrowingContinuation { cont in
            Task { @MainActor in
                let handler: (OAuthToken?, Error?) -> Void = { token, error in
                    if let error {
                        cont.resume(throwing: error)
                    } else if let token {
                        cont.resume(returning: token.accessToken)
                    } else {
                        cont.resume(throwing: NSError(
                            domain: "kakao", code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Empty OAuthToken"]
                        ))
                    }
                }
                if UserApi.isKakaoTalkLoginAvailable() {
                    UserApi.shared.loginWithKakaoTalk(completion: handler)
                } else {
                    UserApi.shared.loginWithKakaoAccount(completion: handler)
                }
            }
        }
    }

    func ensureGoogleConfigured() async throws {
        guard
            let iosClientID = Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String,
            let webClientID = Bundle.main.object(forInfoDictionaryKey: "GoogleWebClientID") as? String
        else {
            throw NSError(
                domain: "google", code: -99,
                userInfo: [NSLocalizedDescriptionKey: "Missing GIDClientID or GoogleWebClientID in Info.plist"]
            )
        }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(
            clientID: iosClientID,
            serverClientID: webClientID
        )
    }

    func googleToken(presenting: UIViewController) async throws -> String {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<String, Error>) in
            GIDSignIn.sharedInstance.signIn(withPresenting: presenting) { result, error in
                if let error {
                    cont.resume(throwing: error)
                } else if let authCode = result?.serverAuthCode, !authCode.isEmpty {
                    cont.resume(returning: authCode)
                } else {
                    cont.resume(throwing: NSError(
                        domain: "google", code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Empty Google serverAuthCode"]
                    ))
                }
            }
        }
    }

    func performAppleLogin(presenting: UIViewController) async throws -> AppleLoginResult {
        try await withCheckedThrowingContinuation { continuation in
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

    public func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        defer { continuation = nil }
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            continuation?.resume(throwing: NSError(domain: "InvalidCredential", code: -1))
            return
        }
        guard
            let authCodeData = credential.authorizationCode,
            let authCode = String(data: authCodeData, encoding: .utf8)
        else {
            continuation?.resume(throwing: NSError(domain: "MissingAuthCode", code: -1))
            return
        }
        let token = credential.identityToken.flatMap { String(data: $0, encoding: .utf8) }
        continuation?.resume(returning: AppleLoginResult(
            serverAuthCode: authCode,
            identityToken: token,
            name: credential.fullName?.givenName,
            email: credential.email
        ))
    }

    public func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension SocialLoginServiceImpl: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.windows.first }
            .first ?? ASPresentationAnchor()
    }
}

// MARK: - AppleLoginResult

private struct AppleLoginResult {
    let serverAuthCode: String
    let identityToken: String?
    let name: String?
    let email: String?
}
