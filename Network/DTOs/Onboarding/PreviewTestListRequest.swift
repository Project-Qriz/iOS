//
//  PreviewTestListRequest.swift
//  QRIZ
//
//  Created by ch on 4/25/25.
//

import Foundation

struct PreviewTestListRequest: Request {
    typealias Response = PreviewTestListResponse
    private let keyChainManager: KeychainManagerImpl = .init()
    
    var path = "/api/v1/preview/get"
    var method: HTTPMethod = .get
    
    var headers: HTTPHeader {
        let accessToken = keyChainManager.retrieveToken(forKey: "accessToken") ?? ""
        if accessToken.isEmpty { print("PreviewTestListRequest received empty accessToken")}
        return [HTTPHeaderField.authorization.rawValue: accessToken]
    }
}

struct PreviewTestListResponse: Decodable {
    let code: Int
    let msg: String
    let data: dataInfo
    
    struct dataInfo: Decodable {
        let questions: [PreviewTestListQuestions]
    }
    
    struct PreviewTestListQuestions: Decodable {
        let questionId: Int
        let skillId: Int
        let category: Int
        let questino: String
        let description: String?
        let options: [PreviewTestListOptions]
        let timeLimit: Int
        let difficulty: Int
    }
    
    struct PreviewTestListOptions: Decodable {
        let id: Int
        let content: String
    }
}
