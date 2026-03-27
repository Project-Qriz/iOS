//
//  ExamResultRequest.swift
//  QRIZ
//
//  Created by ch on 5/6/25.
//

import QRIZUtils

public struct ExamResultRequest: Request, Sendable {
    public typealias Response = ExamResultResponse
    
    public let method: HTTPMethod = .get
    private let accessToken: String
    private let examId: Int
    
    public var path: String {
        "/api/v1/exam/\(examId)/results"
    }
    
    public var headers: HTTPHeader {
        [
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
    
    public init(accessToken: String, examId: Int) {
        self.accessToken = accessToken
        self.examId = examId
    }
}

public struct ExamResultResponse: Decodable, Sendable {
    public let code: Int
    public let msg: String
    public let data: DataInfo
    
    public struct DataInfo: Decodable, Sendable {
        public let problemResults: [ProblemResult]
        public let historicalScores: [HistoricalScore]
    }
    
    public struct ProblemResult: Decodable, Sendable {
        public let questionId: Int
        public let questionNum: Int
        public let skillName: String
        public let question: String
        public let correction: Bool
    }
}

public struct HistoricalScore: Decodable, Comparable, Sendable {
    public let completionDateTime: String
    public let itemScores: [ItemScore]
    public let attemptCount: Int
    public let displayDate: String
    
    public struct ItemScore: Decodable, Sendable {
        public let type: String
        public let score: Double
    }
    
    public static func < (lhs: HistoricalScore, rhs: HistoricalScore) -> Bool {
        lhs.displayDate < rhs.displayDate
    }
    
    public static func == (lhs: HistoricalScore, rhs: HistoricalScore) -> Bool {
        lhs.displayDate == rhs.displayDate
    }

    public func toEntity() -> HistoricalScoreEntity {
        HistoricalScoreEntity(
            completionDateTime: completionDateTime,
            itemScores: itemScores.map { ItemScoreEntity(type: $0.type, score: $0.score) },
            attemptCount: attemptCount,
            displayDate: displayDate
        )
    }
}
