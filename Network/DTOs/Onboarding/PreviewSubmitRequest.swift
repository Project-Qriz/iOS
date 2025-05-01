//
//  PreviewSubmitRequest.swift
//  QRIZ
//
//  Created by ch on 4/25/25.
//

import Foundation

struct PreviewSubmitRequest: Request {
    
    // MARK: - Properties
    typealias Response = PreviewSubmitResponse
    private let accessToken: String
    
    let path = "/api/v1/preview/submit"
    let method: HTTPMethod = .post
    private let testSubmitDataList: [TestSubmitData]
    var body: Encodable? {
        [
            "activities": testSubmitDataList
        ]
    }
    
    var headers: HTTPHeader {
        return [
            HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue,
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
    
    // MARK: - Initializers
    init(accessToken: String, testSubmitDataList: [TestSubmitData]) {
        self.accessToken = accessToken
        self.testSubmitDataList = testSubmitDataList
    }
}

struct PreviewSubmitResponse: Decodable {
    let code: Int
    let msg: String
    let data: String?
}
