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

    let path = "/api/v1/preview/get"
    let method: HTTPMethod = .get
    private let accessToken: String
    
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
        let questions: [PreviewTestListQuestion]
        let totalTimeLimit: Int
    }
}

struct PreviewTestListQuestion: Decodable {
    let questionId: Int
    let skillId: Int
    let category: Int
    let question: String
    let description: String?
    let options: [PreviewTestListOption]
    let timeLimit: Int
    let difficulty: Int
}

struct PreviewTestListOption: Decodable {
    let id: Int
    let content: String
}
