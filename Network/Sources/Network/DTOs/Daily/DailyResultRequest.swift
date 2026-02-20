//
//  DailyResultRequest.swift
//  QRIZ
//
//  Created by 이창현 on 5/1/25.
//

import Foundation

public struct DailyResultRequest: Request, Sendable {
    public typealias Response = DailyResultResponse
    
    public let method: HTTPMethod = .get
    private let accessToken: String
    private let dayNumber: Int
    
    public var path: String {
        "/api/v1/daily/subject-details/\(dayNumber)"
    }
    
    public var headers: HTTPHeader {
        [
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
    
    public init(accessToken: String, dayNumber: Int) {
        self.accessToken = accessToken
        self.dayNumber = dayNumber
    }
}

public struct DailyResultResponse: Decodable, Sendable {
    public let code: Int
    public let msg: String
    public let data: DataInfo
    
    public struct DataInfo: Decodable, Sendable {
        public let dayNumber: String
        public let passed: Bool
        public let reviewDay: Bool
        public let comprehensiveReviewDay: Bool
        public let items: [ItemInfo]
        public let subjectResultsList: [SubjectResult]
        public let totalScore: CGFloat

        public struct ItemInfo: Decodable, Sendable {
            public let skillId: Int
            public let score: CGFloat
        }
    }
}

public struct SubjectResult: Decodable, Sendable {
    public let questionId: Int
    public let detailType: String
    public let question: String
    public let correction: Bool
}
