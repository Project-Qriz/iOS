//
//  VersionRequest.swift
//  QRIZ
//
//  Created by 김세훈 on 6/9/25.
//

import Foundation

struct VersionRequest: Request {
    typealias Response = VersionResponse
    
    private let accessToken: String
    let path = "/api/v1/version"
    let method: HTTPMethod = .get
    
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

struct VersionResponse: Decodable {
    let code: Int
    let msg: String
    let data: VersionData
}

struct VersionData: Decodable {
    let versionInfo: Float
    let updateInfo: String
    let date: String
}
