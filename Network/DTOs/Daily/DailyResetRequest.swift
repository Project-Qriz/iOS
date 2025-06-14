//
//  DailyResetRequest.swift
//  QRIZ
//
//  Created by 김세훈 on 6/14/25.
//

import Foundation

struct DailyResetRequest: Request {
    typealias Response = DailyResetResponse
    
    private let accessToken: String
    let path = "/api/v1/daily/regenerate"
    let method: HTTPMethod = .post
    
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

struct DailyResetResponse: Decodable {
    let code: Int
    let msg: String
}
