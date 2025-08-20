//
//  SocialLoginService.swift
//  QRIZ
//
//  Created by 김세훈 on 8/18/25.
//

import Foundation
import KakaoSDKAuth
import KakaoSDKUser

protocol SocialLoginService {
    func loginWithKakao() async throws -> SocialLoginResponse
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
}
