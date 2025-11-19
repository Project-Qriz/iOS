//
//  SocialLogoutRequest.swift
//  QRIZ
//
//  Created by 김세훈 on 11/19/25.
//

import Foundation

struct SocialLogoutRequest: Request {
    typealias Response = SocialLogoutResponse
    
    private let accessToken: String
    let path = "/api/logout"
    let method: HTTPMethod = .post
    
    var headers: HTTPHeader {
        [
            HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue,
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
}

struct SocialLogoutResponse: Decodable {
    let code: Int
    let msg: String
    let data: String?
}
