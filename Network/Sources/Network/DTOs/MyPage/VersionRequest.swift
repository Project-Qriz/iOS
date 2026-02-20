//
//  VersionRequest.swift
//  QRIZ
//
//  Created by 김세훈 on 6/9/25.
//

public struct VersionRequest: Request, Sendable {
    public typealias Response = VersionResponse
    
    private let accessToken: String
    public let path = "/api/v1/version"
    public let method: HTTPMethod = .get
    
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

public struct VersionResponse: Decodable, Sendable {
    public let code: Int
    public let msg: String
    public let data: VersionData
}

public struct VersionData: Decodable, Sendable {
    public let versionInfo: Float
    public let updateInfo: String
    public let date: String
}
