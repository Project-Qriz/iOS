//
//  PreviewTestListRequest.swift
//  QRIZ
//
//  Created by ch on 4/25/25.
//

public struct PreviewTestListRequest: Request, Sendable {
    public typealias Response = PreviewTestListResponse

    public let path = "/api/v1/preview/get"
    public let method: HTTPMethod = .get
    private let accessToken: String
    
    public var headers: HTTPHeader {
        [
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
    
    public init(accessToken: String) {
        self.accessToken = accessToken
    }
}

public struct PreviewTestListResponse: Decodable, Sendable {
    public let code: Int
    public let msg: String
    public let data: DataInfo

    public init(code: Int, msg: String, data: DataInfo) {
        self.code = code; self.msg = msg; self.data = data
    }

    public struct DataInfo: Decodable, Sendable {
        public let questions: [PreviewTestListQuestion]
        public let totalTimeLimit: Int

        public init(questions: [PreviewTestListQuestion], totalTimeLimit: Int) {
            self.questions = questions; self.totalTimeLimit = totalTimeLimit
        }
    }
}

public struct PreviewTestListQuestion: Decodable, Sendable {
    public let questionId: Int
    public let skillId: Int
    public let category: Int
    public let question: String
    public let description: String?
    public let options: [PreviewTestListOption]
    public let timeLimit: Int
    public let difficulty: Int

    public init(questionId: Int, skillId: Int, category: Int, question: String,
                description: String?, options: [PreviewTestListOption],
                timeLimit: Int, difficulty: Int) {
        self.questionId = questionId; self.skillId = skillId; self.category = category
        self.question = question; self.description = description; self.options = options
        self.timeLimit = timeLimit; self.difficulty = difficulty
    }
}

public struct PreviewTestListOption: Decodable, Sendable {
    public let id: Int
    public let content: String

    public init(id: Int, content: String) {
        self.id = id; self.content = content
    }
}
