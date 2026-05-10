//
//  ExamQuestionRequest.swift
//  QRIZ
//
//  Created by ch on 5/3/25.
//

public struct ExamQuestionRequest: Request, Sendable {
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
    
    public init(accessToken: String, examId: Int) {
        self.accessToken = accessToken
        self.examId = examId
    }
}

public struct ExamQuestionResponse: Decodable, Sendable {
    public let code: Int
    public let msg: String
    public let data: ExamTestInfo

    public init(code: Int, msg: String, data: ExamTestInfo) {
        self.code = code
        self.msg = msg
        self.data = data
    }

    public struct ExamTestInfo: Decodable, Sendable {
        public let questions: [ExamQuestionInfo]
        public let totalTimeLimit: Int

        public init(questions: [ExamQuestionInfo], totalTimeLimit: Int) {
            self.questions = questions
            self.totalTimeLimit = totalTimeLimit
        }
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

    public init(
        questionId: Int,
        skillId: Int,
        category: Int,
        question: String,
        description: String?,
        options: [OptionInfo],
        timeLimit: Int,
        difficulty: Int
    ) {
        self.questionId = questionId
        self.skillId = skillId
        self.category = category
        self.question = question
        self.description = description
        self.options = options
        self.timeLimit = timeLimit
        self.difficulty = difficulty
    }

    public struct OptionInfo: Decodable, Sendable {
        public let id: Int
        public let content: String
        public let contentType: String

        public init(id: Int, content: String, contentType: String) {
            self.id = id
            self.content = content
            self.contentType = contentType
        }
    }
}
