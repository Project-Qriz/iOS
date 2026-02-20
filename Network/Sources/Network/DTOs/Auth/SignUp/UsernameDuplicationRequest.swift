//
//  UsernameDuplicationRequest.swift
//  QRIZ
//
//  Created by 김세훈 on 3/13/25.
//

import Foundation


public struct UsernameDuplicationRequest: Request, Sendable {
    public typealias Response = UsernameDuplicationResponse
    
    public let path = "/api/username-duplicate"
    public let method: HTTPMethod = .get
    public let username: String
    
    public var query: QueryItems {
        ["username": username]
    }
    
    public var headers: HTTPHeader {
        [HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue]
    }
}

public struct UsernameDuplicationResponse: Decodable, Sendable {
    public let code: Int
    public let msg: String
    public let data: DataInfo

    public struct DataInfo: Decodable, Sendable {
        public let available: Bool
    }
}
