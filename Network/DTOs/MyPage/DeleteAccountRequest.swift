//
//  DeleteAccountRequest.swift
//  QRIZ
//
//  Created by 김세훈 on 6/18/25.
//

import Foundation

struct DeleteAccountRequest: Request {
    typealias Response = DeleteAccountResponse
    
    private let accessToken: String
    let path = "/api/v1/withdraw"
    let method: HTTPMethod = .delete
    
    var headers: HTTPHeader {
        [
            HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue,
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
    
    init(accessToken: String) {
        self.accessToken = accessToken
    }
}

struct DeleteAccountResponse: Decodable {
    let code: Int
    let msg: String
}

