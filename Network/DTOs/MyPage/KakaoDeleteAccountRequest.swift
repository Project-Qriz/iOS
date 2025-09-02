//
//  KakaoDeleteAccountRequest.swift
//  QRIZ
//
//  Created by 김세훈 on 9/2/25.
//

import Foundation

struct KakaoDeleteAccountRequest: Request {
    typealias Response = KakaoDeleteAccountResponse
    
    private let accessToken: String
    let path = "/api/auth/social/kakao/withdraw"
    let method: HTTPMethod = .delete
    
    var headers: HTTPHeader {
        [
            HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue,
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
    
    init(accessToken: String) {
        self.accessToken = accessToken
    }
}

struct KakaoDeleteAccountResponse: Decodable {
    let code: Int
    let msg: String
}
