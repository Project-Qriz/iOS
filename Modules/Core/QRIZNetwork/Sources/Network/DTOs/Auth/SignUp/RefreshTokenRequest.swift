//
//  RefreshTokenRequest.swift
//  QRIZ
//
//  Created by 김세훈 on 11/10/25.
//

import Foundation

public struct RefreshTokenRequest: Request, Sendable {
    public typealias Response = RefreshTokenResponse

    public let path = "/api/v1/auth/token/refresh"
    public let method: HTTPMethod = .post
    private let accessToken: String
    private let refreshToken: String

    public var body: Encodable? {
        ["refreshToken": refreshToken]
    }

    public var headers: HTTPHeader {
        [
            HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue,
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }

    public init(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}

public struct RefreshTokenResponse: Decodable, Sendable {
    public let code: Int
    public let msg: String
    public let reason: String?
    public let detailCode: Int?
    public let data: DataInfo?
    
    public struct DataInfo: Decodable, Sendable {
        public let rotated: Bool? // 3일 이하 true
        public let refreshExpiry: String? // rotated == true 일 때만 존재
        public let refreshToken: String?
    }
}
