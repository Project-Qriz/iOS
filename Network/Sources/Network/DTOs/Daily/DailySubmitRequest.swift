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
    private let dailySubmitData: [DailySubmitData]
    
    public var path: String {
        "/api/v1/daily/submit/\(dayNumber)"
    }
    
    public var body: Encodable? {
        [
            "activities": dailySubmitData
        ]
    }
    
    public var headers: HTTPHeader {
        [
            HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue,
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
    
    public init(accessToken: String, dayNumber: Int, dailySubmitData: [DailySubmitData]) {
        self.accessToken = accessToken
        self.dayNumber = dayNumber
        self.dailySubmitData = dailySubmitData
    }
}

public struct DailySubmitResponse: Decodable, Sendable {
    public let code: Int
    public let msg: String
    public let data: String?
}
