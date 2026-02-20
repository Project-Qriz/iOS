//
//  ExamScoreRequest.swift
//  QRIZ
//
//  Created by ch on 5/3/25.
//

import Foundation

public struct ExamScoreRequest: Request, Sendable {
    
    // MARK: - Properties
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
    
    // MARK: - Initializers
    public init(accessToken: String, examId: Int) {
        self.accessToken = accessToken
        self.examId = examId
    }
}

public struct ExamScoreResponse: Decodable, Sendable {
    public let code: Int
    public let msg: String
    public let data: [SubjectInfo]
    
    public struct SubjectInfo: Decodable, Sendable {
        public let title: String
        public let totalScore: CGFloat
        public let majorItems: [MajorItemInfo]
        
        public struct MajorItemInfo: Decodable, Sendable {
            public let majorItem: String
            public let score: CGFloat
            public let subItemScores: [SubItemInfo]
        }
    }
}
