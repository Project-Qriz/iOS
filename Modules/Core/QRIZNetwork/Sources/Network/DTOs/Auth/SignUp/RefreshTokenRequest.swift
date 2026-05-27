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

    public init(code: Int, msg: String, reason: String? = nil, detailCode: Int? = nil, data: DataInfo? = nil) {
        self.code = code
        self.msg = msg
        self.reason = reason
        self.detailCode = detailCode
        self.data = data
    }

    public struct DataInfo: Decodable, Sendable {
        public let rotated: Bool?
        public let refreshExpiry: String?
        public let refreshToken: String?

        public init(rotated: Bool? = nil, refreshExpiry: String? = nil, refreshToken: String? = nil) {
            self.rotated = rotated
            self.refreshExpiry = refreshExpiry
            self.refreshToken = refreshToken
        }
    }
}
