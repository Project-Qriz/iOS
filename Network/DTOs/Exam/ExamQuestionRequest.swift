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

    let method: HTTPMethod = .get
    private let accessToken: String
    private let examId: Int

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
    let data: ExamTestInfo

    struct ExamTestInfo: Decodable {
        let questions: [ExamQuestionInfo]
        let totalTimeLimit: Int
    }
}

struct ExamQuestionInfo: Decodable {
    let questionId: Int
    let skillId: Int
    let category: Int
    let question: String
    let description: String?
    let options: [OptionInfo]
    let timeLimit: Int
    let difficulty: Int
    
    struct OptionInfo: Decodable {
        let id: Int
        let content: String
    }
}
