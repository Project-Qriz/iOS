//
//  TestSubmitRequest.swift
//  QRIZ
//
//  Created by ch on 5/3/25.
//

import QRIZUtils

public struct TestSubmitRequest: Request, Sendable {
    
    // MARK: - Properties
    public typealias Response = TestSubmitResponse

    public let method: HTTPMethod = .post
    private let accessToken: String
    private let examId: Int
    private let testSubmitData: [TestSubmitData]
    
    public var path: String {
        "/api/v1/exam/submit/\(examId)"
    }

    public var body: Encodable? {
        [
            "activities": testSubmitData
        ]
    }
    
    public var headers: HTTPHeader {
        [
            HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue,
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
    
    // MARK: - Initializers
    public init(accessToken: String, examId: Int, testSubmitData: [TestSubmitData]) {
        self.accessToken = accessToken
        self.examId = examId
        self.testSubmitData = testSubmitData
    }
}

public struct TestSubmitResponse: Decodable, Sendable {
    public let code: Int
    public let msg: String
    public let data: String?
}
