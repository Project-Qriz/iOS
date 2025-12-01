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


import Foundation

struct SocialLoginRequest: Request {
    typealias Response = SocialLoginResponse
        
    let method: HTTPMethod = .post
    let provider: SocialLogin
    let authCode: String
    let idToken: String? // Apple
    let name: String? // Apple
    let email: String? // Apple
    
    var path: String {
        switch provider {
        case .apple:
            return "/api/auth/social/login/apple"
        default:
            return "/api/auth/social/login"
        }
    }
    
    var body: Encodable? {
        var body: [String: String] = [
            "provider": provider.rawValue,
            provider.codeKey: authCode,
            "platform": "ios"
        ]
        if provider == .apple {
            if let idToken = idToken { body["authCode"] = idToken }
            if let name = name { body["name"] = name }
            if let email = email { body["email"] = email }
        }
        
        return body
    }
    
    var headers: HTTPHeader {
        [HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue]
    }
    
    
    /// Apple 로그인용 Init
    init(
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
    init(provider: SocialLogin, token: String) {
        self.provider = provider
        self.authCode = token
        self.idToken = nil
        self.name = nil
        self.email = nil
    }
}

struct SocialLoginResponse: Decodable {
    let code: Int
    let msg: String
    let data: DataInfo
    
    struct DataInfo: Decodable {
        let refreshToken: String?
        let refreshExpiry: String?
        let user: UserInfo
    }
}
