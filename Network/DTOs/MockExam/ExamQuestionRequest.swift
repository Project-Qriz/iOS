//
//  ExamQuestionRequest.swift
//  QRIZ
//
//  Created by ch on 5/3/25.
//

import Foundation

struct ExamQuestionRequest: Request {
    
    // MARK: - Properties
    typealias Response = ExamQuestionResponse
    private let accessToken: String
    
    private let examId: Int
    let method: HTTPMethod = .get
    var path: String {
        "/api/v1/exam/get/\(examId)"
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

struct ExamQuestionResponse: Decodable {
    let code: Int
    let msg: String
    let data: DataInfo
    
    struct DataInfo: Decodable {
        let questions: [QuestionInfo]
        let totalTimeLimit: Int
        
        struct QuestionInfo: Decodable {
            let questionId: Int
            let skillId: Int
            let category: Int
            let question: String
            let description: String?
            let option1: String
            let option2: String
            let option3: String
            let option4: String
            let timeLimit: Int
        }
    }
}
