//
//  DeleteAccountRequest.swift
//  QRIZ
//
//  Created by 김세훈 on 6/18/25.
//

public struct DeleteAccountRequest: Request, Sendable {
    public typealias Response = DeleteAccountResponse
    
    public let path = "/api/v1/withdraw"
    public let method: HTTPMethod = .delete
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

public struct DeleteAccountResponse: Decodable, Sendable {
    public let code: Int
    public let msg: String
}
