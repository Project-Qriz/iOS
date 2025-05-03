//
//  TestSubmitRequest.swift
//  QRIZ
//
//  Created by ch on 5/3/25.
//

import Foundation

struct TestSubmitRequest: Request {
    
    // MARK: - Properties
    typealias Response = TestSubmitResponse

    private let accessToken: String
    let path = "/api/v1/exam/submit"
    let method: HTTPMethod = .post
    private let testSubmitData: [TestSubmitData]

    var body: Encodable? {
        [
            "activities": testSubmitData
        ]
    }
    
    var headers: HTTPHeader {
        [
            HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue,
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
    
    // MARK: - Initializers
    init(accessToken: String, testSubmitData: [TestSubmitData]) {
        self.accessToken = accessToken
        self.testSubmitData = testSubmitData
    }
}

struct TestSubmitResponse: Decodable {
    let code: Int
    let msg: String
    let data: String? // **** 확인 필요 ****
}
