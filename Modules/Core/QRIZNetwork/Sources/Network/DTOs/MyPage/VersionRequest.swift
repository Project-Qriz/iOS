//
//  VersionRequest.swift
//  QRIZ
//
//  Created by 김세훈 on 6/9/25.
//

public struct VersionRequest: Request, Sendable {
    public typealias Response = VersionResponse
    
    public let path = "/api/v1/version"
    public let method: HTTPMethod = .get
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

public struct VersionResponse: Decodable, Sendable {
    public let code: Int
    public let msg: String
    public let data: VersionData

    public init(code: Int, msg: String, data: VersionData) {
        self.code = code
        self.msg = msg
        self.data = data
    }
}

public struct VersionData: Decodable, Sendable {
    public let versionInfo: String
    public let updateInfo: String
    public let date: String

    public init(versionInfo: String, updateInfo: String, date: String) {
        self.versionInfo = versionInfo
        self.updateInfo = updateInfo
        self.date = date
    }
}
