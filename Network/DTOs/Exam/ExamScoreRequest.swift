//
//  ExamScoreRequest.swift
//  QRIZ
//
//  Created by ch on 5/3/25.
//

import Foundation

struct ExamScoreRequest: Request {
    
    // MARK: - Properties
    typealias Response = ExamScoreResponse
    
    let method: HTTPMethod = .get
    private let accessToken: String
    private let examId: Int
    
    var path: String {
        "/api/v1/exam/\(examId)/subject-details"
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

struct ExamScoreResponse: Decodable {
    let code: Int
    let msg: String
    let data: [SubjectInfo]
    
    struct SubjectInfo: Decodable {
        let title: String
        let totalScore: CGFloat
        let majorItems: [MajorItemInfo]
        
        struct MajorItemInfo: Decodable {
            let majorItem: String
            let score: CGFloat
            let subItemScores: [SubItemInfo]
        }
    }
}
