//
//  DailyPlanSelectRequest.swift
//  QRIZ
//
//  Created by 김세훈 on 5/1/26.
//

import QRIZUtils

public struct DailyPlanSelectRequest: Request, Sendable {
    public typealias Response = DailyPlanSelectResponse

    public let path = "/api/v1/daily/plan/select"
    public let method: HTTPMethod = .post
    private let accessToken: String
    private let planType: Int

    public var headers: HTTPHeader {
        [
            HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue,
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }

    public var body: Encodable? {
        ["planType": planType]
    }

    public init(accessToken: String, planType: Int) {
        self.accessToken = accessToken
        self.planType = planType
    }
}

public struct DailyPlanSelectResponse: Decodable, Sendable {
    public let code: Int
    public let msg: String

    public init(code: Int, msg: String) {
        self.code = code
        self.msg = msg
    }
}
