//
//  ExamResultRequest.swift
//  QRIZ
//
//  Created by ch on 5/6/25.
//

import Foundation

struct ExamResultRequest: Request {
    
    // MARK: - Properties
    typealias Response = ExamResultResponse
    
    let method: HTTPMethod = .get
    private let accessToken: String
    private let examId: Int
    
    var path: String {
        "/api/v1/exam/\(examId)/results"
    }
    
    var headers: HTTPHeader {
        [
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
    
    // MARK: - Initializers
    init(accessToken: String, examId: Int) {
        self.accessToken = accessToken
        self.examId = examId
    }
}

struct ExamResultResponse: Decodable {
    let code: Int
    let msg: String
    let data: DataInfo
    
    struct DataInfo: Decodable {
        let problemResults: [ProblemResult]
        let historicalScores: [HistoricalScore]
    }
    
    struct ProblemResult: Decodable {
        let questionId: Int
        let questionNum: Int
        let skillName: String
        let question: String
        let correction: Bool
    }
}

struct HistoricalScore: Decodable {
    let completionDateTime: String
    let itemScores: [ItemScore]
    let attemptCount: Int
    let displayDate: String
    
    struct ItemScore: Decodable {
        let type: String
        let score: CGFloat
    }
}
