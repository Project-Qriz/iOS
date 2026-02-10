//
//  CompletedDaysRequest.swift
//  QRIZ
//
//  Created by Claude on 1/12/26.
//

import Foundation

/// 완료한 데일리 리스트 조회
struct CompletedDailyDaysRequest: Request {
    typealias Response = CompletedDailyDaysResponse

    let accessToken: String
    let path = "/api/v1/clips/days"
    let method: HTTPMethod = .get

    var headers: HTTPHeader {
        [
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
}

struct CompletedDailyDaysResponse: Decodable {
    let code: Int
    let msg: String
    let data: CompletedDailyDaysData
}

struct CompletedDailyDaysData: Decodable {
    let days: [String]
}
