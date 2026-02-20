//
//  ExamQuestionRequest.swift
//  QRIZ
//
//  Created by ch on 5/3/25.
//

public struct ExamQuestionRequest: Request, Sendable {
    
    // MARK: - Properties
    public typealias Response = ExamQuestionResponse

    public let method: HTTPMethod = .get
    private let accessToken: String
    private let examId: Int

    public var path: String {
        "/api/v1/exam/get/\(examId)"
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

public struct ExamQuestionResponse: Decodable, Sendable {
    public let code: Int
    public let msg: String
    public let data: ExamTestInfo

    public struct ExamTestInfo: Decodable, Sendable {
        public let questions: [ExamQuestionInfo]
        public let totalTimeLimit: Int
    }
}

public struct ExamQuestionInfo: Decodable, Sendable {
    public let questionId: Int
    public let skillId: Int
    public let category: Int
    public let question: String
    public let description: String?
    public let options: [OptionInfo]
    public let timeLimit: Int
    public let difficulty: Int
    
    public struct OptionInfo: Decodable, Sendable {
        public let id: Int
        public let content: String
    }
}
