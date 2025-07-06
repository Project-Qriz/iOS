//
//  VerifyPasswordResetRequest.swift
//  QRIZ
//
//  Created by 김세훈 on 3/19/25.
//

import Foundation

struct VerifyPasswordResetRequest: Request {
    typealias Response = VerifyPasswordResetResponse
    
    let path = "/api/verify-pwd-reset"
    let method: HTTPMethod = .post
    let email: String
    let authNumber: String
    
    var body: Encodable? {
        [
            "email": email,
            "authNumber": authNumber
        ]
    }
    
    var headers: HTTPHeader {
        [HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue]
    }
}

struct VerifyPasswordResetResponse: Decodable {
    let code: Int
    let msg: String
    let data: DataInfo
    
    struct DataInfo: Decodable {
        let resetToken: String
    }
}
