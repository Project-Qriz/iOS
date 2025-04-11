//
//  EmailAuthenticationRequest.swift
//  QRIZ
//
//  Created by 김세훈 on 4/11/25.
//

import Foundation

struct EmailAuthenticationRequest: Request {
    typealias Response = EmailAuthenticationResponse
    
    let path = "/api/email-authentication"
    let method: HTTPMethod = .post
    let authNumber: String
    
    var query: QueryItems {
        ["authNum": authNumber]
    }
    
    var headers: HTTPHeader {
        [HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue]
    }
}

struct EmailAuthenticationResponse: Decodable {
    let code: Int
    let msg: String
    let data: String
}
