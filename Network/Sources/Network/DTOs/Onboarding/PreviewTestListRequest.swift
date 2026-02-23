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
    
    public struct DataInfo: Decodable, Sendable {
        public let questions: [PreviewTestListQuestion]
        public let totalTimeLimit: Int
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
}

public struct PreviewTestListOption: Decodable, Sendable {
    public let id: Int
    public let content: String
}
