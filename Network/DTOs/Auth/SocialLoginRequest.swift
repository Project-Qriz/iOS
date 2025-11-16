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
    
    let path = "/api/auth/social/login"
    let method: HTTPMethod = .post
    let provider: SocialLogin
    let authCode: String
    let name: String?
    let email: String?
    
    var body: Encodable? {
        var body: [String: String] = [
            "provider": provider.rawValue,
            provider.codeKey: authCode,
            "platform": "ios"
        ]
        if provider == .apple {
            if let name = name { body["name"] = name }
            if let email = email { body["email"] = email }
        }
        
        return body
    }
    
    var headers: HTTPHeader {
        [HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue]
    }
    
    
    /// Apple 로그인용 Init
    init(provider: SocialLogin, authCode: String, name: String?, email: String?) {
        self.provider = provider
        self.authCode = authCode
        self.name = name
        self.email = email
    }
    
    /// Google/Kakao 로그인용 Init
    init(provider: SocialLogin, authCode: String) {
        self.provider = provider
        self.authCode = authCode
        self.name = nil
        self.email = nil
    }
}

struct SocialLoginResponse: Decodable {
    let code: Int
    let msg: String
    let refreshToken: String?
    let refreshExpiry: String?
    let data: DataInfo
    
    struct DataInfo: Decodable {
        let provider: String?
        let email: String
        let nickname: String
        let previewStatus: PreviewTestStatus
    }
}
