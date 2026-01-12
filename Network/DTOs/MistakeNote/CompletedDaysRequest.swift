//
//  CompletedDaysRequest.swift
//  QRIZ
//
//  Created by Claude on 1/12/26.
//

import Foundation

struct CompletedDaysRequest: Request {
    typealias Response = CompletedDaysResponse

    let accessToken: String
    let path = "/api/v1/clips/days"
    let method: HTTPMethod = .get

    var headers: HTTPHeader {
        [
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
}

struct CompletedDaysResponse: Decodable {
    let code: Int
    let msg: String
    let data: CompletedDaysData
}

struct CompletedDaysData: Decodable {
    let days: [String]
}
