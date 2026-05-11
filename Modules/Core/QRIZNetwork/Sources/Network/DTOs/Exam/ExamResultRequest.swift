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

    public init(code: Int, msg: String, data: DataInfo) {
        self.code = code
        self.msg = msg
        self.data = data
    }

    public struct DataInfo: Decodable, Sendable {
        public let problemResults: [ProblemResult]
        public let historicalScores: [HistoricalScore]

        public init(problemResults: [ProblemResult], historicalScores: [HistoricalScore]) {
            self.problemResults = problemResults
            self.historicalScores = historicalScores
        }
    }

    public struct ProblemResult: Decodable, Sendable {
        public let questionId: Int
        public let questionNum: Int
        public let skillName: String
        public let question: String
        public let correction: Bool

        public init(questionId: Int, questionNum: Int, skillName: String, question: String, correction: Bool) {
            self.questionId = questionId
            self.questionNum = questionNum
            self.skillName = skillName
            self.question = question
            self.correction = correction
        }
    }
}

public struct HistoricalScore: Decodable, Comparable, Sendable {
    public let completionDateTime: String
    public let itemScores: [ItemScore]
    public let attemptCount: Int
    public let displayDate: String

    public init(completionDateTime: String, itemScores: [ItemScore], attemptCount: Int, displayDate: String) {
        self.completionDateTime = completionDateTime
        self.itemScores = itemScores
        self.attemptCount = attemptCount
        self.displayDate = displayDate
    }

    public struct ItemScore: Decodable, Sendable {
        public let type: String
        public let score: Double

        public init(type: String, score: Double) {
            self.type = type
            self.score = score
        }
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
