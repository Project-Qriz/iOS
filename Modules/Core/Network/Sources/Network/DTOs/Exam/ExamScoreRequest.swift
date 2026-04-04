//
//  ExamScoreRequest.swift
//  QRIZ
//
//  Created by ch on 5/3/25.
//

import Foundation

public struct ExamScoreRequest: Request, Sendable {
    public typealias Response = ExamScoreResponse
    
    public let method: HTTPMethod = .get
    private let accessToken: String
    private let examId: Int
    
    public var path: String {
        "/api/v1/exam/\(examId)/subject-details"
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

public struct ExamScoreResponse: Decodable, Sendable {
    public let code: Int
    public let msg: String
    public let data: [SubjectInfo]

    public init(code: Int, msg: String, data: [SubjectInfo]) {
        self.code = code
        self.msg = msg
        self.data = data
    }

    public struct SubjectInfo: Decodable, Sendable {
        public let title: String
        public let totalScore: Double
        public let majorItems: [MajorItemInfo]

        public init(title: String, totalScore: Double, majorItems: [MajorItemInfo]) {
            self.title = title
            self.totalScore = totalScore
            self.majorItems = majorItems
        }

        public struct MajorItemInfo: Decodable, Sendable {
            public let majorItem: String
            public let score: Double
            public let subItemScores: [SubItemInfo]

            public init(majorItem: String, score: Double, subItemScores: [SubItemInfo]) {
                self.majorItem = majorItem
                self.score = score
                self.subItemScores = subItemScores
            }
        }
    }
}
