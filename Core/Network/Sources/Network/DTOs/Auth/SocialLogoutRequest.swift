//
//  SocialLogoutRequest.swift
//  QRIZ
//
//  Created by 김세훈 on 11/19/25.
//

public struct SocialLogoutRequest: Request, Sendable {
    public typealias Response = SocialLogoutResponse
    
    public let path = "/api/logout"
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

public struct SocialLogoutResponse: Decodable, Sendable {
    public let code: Int
    public let msg: String
    public let data: String?
}
