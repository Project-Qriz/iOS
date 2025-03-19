//
//  UsernameDuplicationRequest.swift
//  QRIZ
//
//  Created by 김세훈 on 3/13/25.
//

import Foundation

struct UsernameDuplicationRequest: Request {
    typealias Response = UsernameDuplicationResponse
    
    let path = "/api/username-duplicate"
    let method: HTTPMethod = .get
    let username: String
    
    var query: QueryItems {
        ["username": username]
    }
    
    var headers: HTTPHeader {
        [HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue]
    }
}

struct UsernameDuplicationResponse: Decodable {
    let code: Int
    let msg: String
    let data: DataInfo

    struct DataInfo: Decodable {
        let available: Bool
    }
}
