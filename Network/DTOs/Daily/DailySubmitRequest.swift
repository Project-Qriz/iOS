//
//  DailySubmitRequest.swift
//  QRIZ
//
//  Created by 이창현 on 4/29/25.
//

import Foundation

struct DailySubmitRequest: Request {
    
    // MARK: - Properties
    typealias Response = DailySubmitResponse
    
    let method: HTTPMethod = .post
    private let accessToken: String
    private let dayNumber: Int
    private let dailySubmitData: [DailySubmitData]

    var path: String {
        "/api/v1/daily/submit/\(dayNumber)"
    }

    var body: Encodable? {
        [
            "activities": dailySubmitData
        ]
    }
    
    var headers: HTTPHeader {
        return [
            HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue,
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
    
    // MARK: - Initializers
    init(accessToken: String, dayNumber: Int, dailySubmitData: [DailySubmitData]) {
        self.accessToken = accessToken
        self.dayNumber = dayNumber
        self.dailySubmitData = dailySubmitData
    }
}

struct DailySubmitResponse: Decodable {
    let code: Int
    let msg: String
    let data: String?
}
