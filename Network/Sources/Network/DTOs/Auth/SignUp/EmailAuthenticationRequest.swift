//
//  EmailAuthenticationRequest.swift
//  QRIZ
//
//  Created by 김세훈 on 4/11/25.
//

import Foundation
public struct EmailAuthenticationRequest: Request, Sendable {
    public typealias Response = EmailAuthenticationResponse
    
    public let path = "/api/email-authentication"
    public let method: HTTPMethod = .post
    public let email: String
    public let authNumber: String
    
    public var body: Encodable? {
        [
            "email": email,
            "authNum": authNumber
        ]
    }
    
    public var headers: HTTPHeader {
        [HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue]
    }
}

public struct EmailAuthenticationResponse: Decodable, Sendable {
    public let code: Int
    public let msg: String
}
