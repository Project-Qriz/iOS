//
//  DailyResetRequest.swift
//  QRIZ
//
//  Created by 김세훈 on 6/14/25.
//

public struct DailyResetRequest: Request, Sendable {
    public typealias Response = DailyResetResponse
    
    public let path = "/api/v1/daily/regenerate"
    public let method: HTTPMethod = .post
    private let accessToken: String
    
    public var headers: HTTPHeader {
        [
            HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue,
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
    
    public init(accessToken: String) {
        self.accessToken = accessToken
    }
}

public struct DailyResetResponse: Decodable, Sendable {
    public let code: Int
    public let msg: String
}
