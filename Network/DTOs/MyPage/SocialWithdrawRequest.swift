//
//  SocialWithdrawRequest.swift
//  QRIZ
//
//  Created by 김세훈 on 9/2/25.
//

import Foundation

struct SocialWithdrawRequest: Request {
    typealias Response = SocialWithdrawResponse
    
    private let socialLoginType: SocialLogin
    private let accessToken: String
    var path: String { "/api/auth/social/\(socialLoginType.rawValue)/withdraw" }
    let method: HTTPMethod = .delete
    
    var headers: HTTPHeader {
        [
            HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue,
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
    
    init(socialLoginType: SocialLogin, accessToken: String) {
        self.socialLoginType = socialLoginType
        self.accessToken = accessToken
    }
}

struct SocialWithdrawResponse: Decodable {
    let code: Int
    let msg: String
}
