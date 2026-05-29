//
//  DailyTestListRequest.swift
//  QRIZ
//
//  Created by 이창현 on 4/29/25.
//

public struct DailyTestListRequest: Request, Sendable {
    public typealias Response = DailyTestListResponse
    
    public let method: HTTPMethod = .get
    private let accessToken: String
    private let dayNumber: Int
    
    public var path: String {
        "/api/v1/daily/get/\(dayNumber)"
    }

    public var headers: HTTPHeader {
        [
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
    
    public init(accessToken: String, dayNumber: Int) {
        self.accessToken = accessToken
        self.dayNumber = dayNumber
    }
}

public struct DailyTestListResponse: Decodable, Sendable {
    public let code: Int
    public let msg: String
    public let data: [DailyTestInfo]?

    public init(code: Int, msg: String, data: [DailyTestInfo]?) {
        self.code = code
        self.msg = msg
        self.data = data
    }
}

public struct DailyTestInfo: Decodable, Sendable {
    public let questionId: Int
    public let skillId: Int
    public let category: Int
    public let question: String
    public let description: String?
    public let options: [OptionInfo]
    public let timeLimit: Int
    public let difficulty: Int

    public init(questionId: Int, skillId: Int, category: Int, question: String, description: String?, options: [OptionInfo], timeLimit: Int, difficulty: Int) {
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
