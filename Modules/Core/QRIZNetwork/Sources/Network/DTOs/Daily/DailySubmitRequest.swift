//
//  DailySubmitRequest.swift
//  QRIZ
//
//  Created by 이창현 on 4/29/25.
//

import QRIZUtils

public struct DailySubmitRequest: Request, Sendable {
    public typealias Response = DailySubmitResponse

    public let method: HTTPMethod = .post
    private let accessToken: String
    private let dayNumber: Int
    private let submissionId: String
    private let dailySubmitData: [DailySubmitData]

    public var path: String {
        "/api/v1/daily/submit/\(dayNumber)"
    }

    public var body: Encodable? {
        DailySubmitBody(submissionId: submissionId, activities: dailySubmitData)
    }

    public var headers: HTTPHeader {
        [
            HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue,
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }

    public init(accessToken: String, dayNumber: Int, submissionId: String, dailySubmitData: [DailySubmitData]) {
        self.accessToken = accessToken
        self.dayNumber = dayNumber
        self.submissionId = submissionId
        self.dailySubmitData = dailySubmitData
    }
}

private struct DailySubmitBody: Encodable {
    let submissionId: String
    let activities: [DailySubmitData]
}

public struct DailySubmitResponse: Decodable, Sendable {
    public let code: Int
    public let msg: String
    public let data: String?
}
