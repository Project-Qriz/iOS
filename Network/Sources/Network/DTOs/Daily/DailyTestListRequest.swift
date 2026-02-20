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
    
    public struct OptionInfo: Decodable, Sendable {
        public let id: Int
        public let content: String
    }
}
