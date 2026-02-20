//
//  AppliedExamsRequest.swift
//  QRIZ
//
//  Created by 김세훈 on 5/1/25.
//

public struct AppliedExamsRequest: Request, Sendable {
    public typealias Response = AppliedExamsResponse

    public let accessToken: String
    public let path = "/api/v1/applications/applied"
    public let method: HTTPMethod = .get

    public var headers: HTTPHeader {
        [
            HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue,
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
}

public struct AppliedExamsResponse: Decodable, Sendable {
    public let code: Int
    public let msg: String
    public let data: ExamInfo

    public struct ExamInfo: Decodable, Sendable {
        public let examName: String
        public let period: String
        public let examDate: String
    }
}
