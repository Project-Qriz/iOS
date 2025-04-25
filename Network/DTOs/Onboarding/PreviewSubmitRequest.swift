//
//  PreviewSubmitRequest.swift
//  QRIZ
//
//  Created by ch on 4/25/25.
//

import Foundation

struct PreviewSubmitRequest: Request {
    typealias Response = PreviewSubmitResponse
    private let keyChainManager: KeychainManagerImpl = .init()
    
    var path = "/api/v1/preview/submit"
    var method: HTTPMethod = .post
    
    var headers: HTTPHeader {
        let accessToken = keyChainManager.retrieveToken(forKey: "accessToken") ?? ""
        if accessToken.isEmpty { print("PreviewSubmitRequest received empty accessToken")}
        return [
            HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue,
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
}

struct PreviewSubmitResponse: Decodable {
    
}
