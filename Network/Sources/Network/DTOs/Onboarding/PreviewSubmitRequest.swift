//
//  PreviewSubmitRequest.swift
//  QRIZ
//
//  Created by ch on 4/25/25.
//

import QRIZUtils

public struct PreviewSubmitRequest: Request, Sendable {
    public typealias Response = PreviewSubmitResponse
    
    public let path = "/api/v1/preview/submit"
    public let method: HTTPMethod = .post
    private let accessToken: String
    private let testSubmitDataList: [TestSubmitData]
    
    public var body: Encodable? {
        [
            "activities": testSubmitDataList
        ]
    }
    
    public var headers: HTTPHeader {
        return [
            HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue,
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
    
    public init(accessToken: String, testSubmitDataList: [TestSubmitData]) {
        self.accessToken = accessToken
        self.testSubmitDataList = testSubmitDataList
    }
}

public struct PreviewSubmitResponse: Decodable, Sendable {
    public let code: Int
    public let msg: String
    public let data: String?
}
