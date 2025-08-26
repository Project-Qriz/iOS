//
//  SocialLoginRequest.swift
//  QRIZ
//
//  Created by 김세훈 on 8/18/25.
//

import Foundation

struct SocialLoginRequest: Request {
    typealias Response = SocialLoginResponse
    
    let path = "/api/auth/social/login"
    let method: HTTPMethod = .post
    let provider: LoginViewModel.SocialLogin
    let authCode: String
    
    var body: Encodable? {
        [
            "provider": provider.rawValue,
            "authCode": authCode,
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
        let previewStatus: String
    }
}
