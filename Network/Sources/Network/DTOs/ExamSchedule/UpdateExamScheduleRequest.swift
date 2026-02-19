//
//  UpdateExamScheduleRequest.swift
//  QRIZ
//
//  Created by 김세훈 on 5/11/25.
//

import Foundation

public struct UpdateExamScheduleRequest: Request , Sendable {
    public typealias Response = UpdateExamScheduleResponse
    
    private let accessToken: String
    private let userApplyId: Int
    private let newApplyId: Int
    
    public var path: String { "/api/v1/applications/\(userApplyId)" }
    public let method: HTTPMethod = .patch
    
    public var headers: HTTPHeader {
        [
            HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue,
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
    
    public var body: Encodable? {
        [
            "newApplyId": newApplyId
        ]
    }
    
    public init(accessToken: String, userApplyId: Int, newApplyId: Int) {
        self.accessToken = accessToken
        self.userApplyId = userApplyId
        self.newApplyId = newApplyId
    }
}

public struct UpdateExamScheduleResponse: Decodable , Sendable {
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
