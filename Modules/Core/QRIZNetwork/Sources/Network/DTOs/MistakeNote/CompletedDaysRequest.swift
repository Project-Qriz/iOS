//
//  CompletedDaysRequest.swift
//  QRIZ
//
//  Created by Claude on 1/12/26.
//

/// 완료한 데일리 리스트 조회
public struct CompletedDailyDaysRequest: Request, Sendable {
    public typealias Response = CompletedDailyDaysResponse

    public let path = "/api/v1/clips/days"
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

public struct CompletedDailyDaysResponse: Decodable, Sendable {
    public let code: Int
    public let msg: String
    public let data: CompletedDailyDaysData

    public init(code: Int, msg: String, data: CompletedDailyDaysData) {
        self.code = code
        self.msg = msg
        self.data = data
    }
}

public struct CompletedDailyDaysData: Decodable, Sendable {
    public let days: [String]

    public init(days: [String]) {
        self.days = days
    }
}
