
//
//  VerifyPasswordResetRequest.swift
//  QRIZ
//
//  Created by 김세훈 on 3/19/25.
//

public struct VerifyPasswordResetRequest: Request, Sendable {
    public typealias Response = VerifyPasswordResetResponse
    
    public let path = "/api/verify-pwd-reset"
    public let method: HTTPMethod = .post
    public let email: String
    public let authNumber: String
    
    public var body: Encodable? {
        [
            "email": email,
            "authNumber": authNumber
        ]
    }
    
    public var headers: HTTPHeader {
        [HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue]
    }
}

public struct VerifyPasswordResetResponse: Decodable, Sendable {
    public let code: Int
    public let msg: String
    public let data: DataInfo
    
    public struct DataInfo: Decodable, Sendable {
        public let resetToken: String
    }
}
