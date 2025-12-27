//
//  RefreshTokenRequest.swift
//  QRIZ
//
//  Created by 김세훈 on 11/10/25.
//

import Foundation

struct RefreshTokenRequest: Request {
    typealias Response = RefreshTokenResponse
    
    let path = "/api/v1/auth/token/refresh"
    let method: HTTPMethod = .post
    let accessToken: String
    let refreshToken: String

    var body: Encodable? {
        ["refreshToken": refreshToken]
    }
    
    var headers: HTTPHeader {
        [
            HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue,
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
}

struct RefreshTokenResponse: Decodable {
    let code: Int
    let msg: String
    let reason: String?
    let detailCode: Int?
    let data: DataInfo?
    
    struct DataInfo: Decodable {
        let rotated: Bool? // 3일 이하 true
        let refreshExpiry: String? // rotated == true 일 때만 존재
        let refreshToken: String?
    }
}
