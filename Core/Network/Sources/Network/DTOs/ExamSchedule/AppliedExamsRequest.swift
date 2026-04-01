//
//  AppliedExamsRequest.swift
//  QRIZ
//
//  Created by 김세훈 on 5/1/25.
//

public struct AppliedExamsRequest: Request, Sendable {
    public typealias Response = AppliedExamsResponse

    public let path = "/api/v1/applications/applied"
    public let method: HTTPMethod = .get
    private let accessToken: String

    public var headers: HTTPHeader {
        [
            HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue,
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }

    public init(accessToken: String) {
        self.accessToken = accessToken
    }
}

public struct AppliedExamsResponse: Decodable, Sendable {
    public let code: Int
    public let msg: String
    public let data: ExamInfo

    public init(code: Int, msg: String, data: ExamInfo) {
        self.code = code
        self.msg = msg
        self.data = data
    }

    public struct ExamInfo: Decodable, Sendable {
        public let examName: String
        public let period: String
        public let examDate: String

        public init(examName: String, period: String, examDate: String) {
            self.examName = examName
            self.period = period
            self.examDate = examDate
        }
    }
}
