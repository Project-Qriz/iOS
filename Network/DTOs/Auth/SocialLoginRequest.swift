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
    
    var body: Encodable? {
        [
            "provider": provider.rawValue,
            provider.codeKey: authCode,
            "platform": "ios"
        ]
    }
    
    var headers: HTTPHeader {
        [HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue]
    }
}

struct SocialLoginResponse: Decodable {
    let code: Int
    let msg: String
    let data: dataInfo
    
    struct dataInfo: Decodable {
        let provider: String
        let email: String
        let nickname: String
        let previewStatus: PreviewTestStatus
    }
}
