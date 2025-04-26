//
//  PreviewTestListRequest.swift
//  QRIZ
//
//  Created by ch on 4/25/25.
//

import Foundation

struct PreviewTestListRequest: Request {
    
    // MARK: - Properties
    typealias Response = PreviewTestListResponse
    private let accessToken: String
    
    var path = "/api/v1/preview/get"
    var method: HTTPMethod = .get
    
    var headers: HTTPHeader {
        [
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
    
    // MARK: - Initializers
    init(accessToken: String) {
        self.accessToken = accessToken
    }
}

struct PreviewTestListResponse: Decodable {
    let code: Int
    let msg: String
    let data: dataInfo
    
    struct dataInfo: Decodable {
        let questions: [PreviewTestListQuestions]
        let totalTimeLimit: Int
    }
    
    struct PreviewTestListQuestions: Decodable {
        let questionId: Int
        let skillId: Int
        let category: Int
        let question: String
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
