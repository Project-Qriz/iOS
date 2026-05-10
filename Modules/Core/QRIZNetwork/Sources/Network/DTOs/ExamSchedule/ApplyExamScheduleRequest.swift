//
//  ApplyExamScheduleRequest.swift
//  QRIZ
//
//  Created by 김세훈 on 5/10/25.
//

public struct ApplyExamScheduleRequest: Request, Sendable {
    public typealias Response = ApplyExamScheduleResponse
    
    public let path = "/api/v1/applications"
    public let method: HTTPMethod = .post
    private let accessToken: String
    private let applyId: Int
    
    public var headers: HTTPHeader {
        [
            HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue,
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
    
    public var body: Encodable? {
        [
            "applyId": applyId
        ]
    }
    
    public init(accessToken: String, applyId: Int) {
        self.accessToken = accessToken
        self.applyId = applyId
    }
}

public struct ApplyExamScheduleResponse: Decodable, Sendable {
    public let code: Int
    public let msg: String
    public let data: ExamInfo?

    public init(code: Int, msg: String, data: ExamInfo?) {
        self.code = code
        self.msg = msg
        self.data = data
    }

    public struct ExamInfo: Decodable, Sendable {
        public let examName: String
        public let period: String
        public let examDate: String
        public let releaseDate: String
    }
}
