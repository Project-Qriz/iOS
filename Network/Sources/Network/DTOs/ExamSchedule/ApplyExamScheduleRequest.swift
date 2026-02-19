//
//  ApplyExamScheduleRequest.swift
//  QRIZ
//
//  Created by 김세훈 on 5/10/25.
//

import Foundation

public struct ApplyExamScheduleRequest: Request , Sendable {
    public typealias Response = ApplyExamScheduleResponse
    
    private let accessToken: String
    private let applyId: Int
    public let path = "/api/v1/applications"
    public let method: HTTPMethod = .post
    
    public var headers: HTTPHeader {
        [
            HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue,
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
    
    public var body: Encodable? {
        [
            "applyId": applyId
        ]
    }
    
    public init(accessToken: String, applyId: Int) {
        self.accessToken = accessToken
        self.applyId = applyId
    }
}

public struct ApplyExamScheduleResponse: Decodable , Sendable {
    public let code: Int
    public let msg: String
    public let data: ExamInfo?

    public struct ExamInfo: Decodable , Sendable {
        public let examName: String
        public let period: String
        public let examDate: String
        public let releaseDate: String
    }
}
