//
//  SocialLoginRequest.swift
//  QRIZ
//
//  Created by 김세훈 on 8/18/25.
//

/*
 {
 "code": 1,
 "msg": "소셜 로그인 성공",
 "data": {
 "provider": "KAKAO",
 "email": "asdfasdf@naver.com",
 "nickname": "김세훈",
 "previewStatus": "SURVEY_COMPLETED"
 }
 }
 */

import QRIZUtils

public struct SocialLoginRequest: Request, Sendable {
    public typealias Response = SocialLoginResponse
    
    public let method: HTTPMethod = .post
    public let provider: SocialLogin
    public let authCode: String
    public let idToken: String? // Apple
    public let name: String? // Apple
    public let email: String? // Apple
    
    public var path: String {
        switch provider {
        case .apple:
            return "/api/auth/social/login/apple"
        default:
            return "/api/auth/social/login"
        }
    }
    
    public var body: Encodable? {
        var params: [String: String] = [
            "provider": provider.rawValue,
            provider.codeKey: authCode,
            "platform": "ios"
        ]
        if provider == .apple {
            if let idToken = idToken { params["authCode"] = idToken }
            if let name = name { params["name"] = name }
            if let email = email { params["email"] = email }
        }
        
        return params
    }
    
    public var headers: HTTPHeader {
        [HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue]
    }
    
    /// Apple 로그인용 Init
    public init(
        provider: SocialLogin,
        serverAuthCode: String,
        idToken: String? = nil,
        name: String? = nil,
        email: String? = nil
    ) {
        self.provider = provider
        self.authCode = serverAuthCode
        self.idToken = idToken
        self.name = name
        self.email = email
    }
    
    /// Google/Kakao 로그인용 Init
    public init(provider: SocialLogin, token: String) {
        self.provider = provider
        self.authCode = token
        self.idToken = nil
        self.name = nil
        self.email = nil
    }
}

public struct SocialLoginResponse: Decodable, Sendable {
    public let code: Int
    public let msg: String
    public let data: DataInfo
    
    public struct DataInfo: Decodable, Sendable {
        public let refreshToken: String?
        public let refreshExpiry: String?
        public let user: UserInfo
    }
}
