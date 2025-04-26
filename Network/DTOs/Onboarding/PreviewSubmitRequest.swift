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
    
    var path = "/api/v1/preview/submit"
    var method: HTTPMethod = .post
    var testSubmitDataList: [TestSubmitData]
    var query: QueryItems {
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
