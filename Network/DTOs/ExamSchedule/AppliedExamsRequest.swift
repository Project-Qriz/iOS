//
//  AppliedExamsRequest.swift
//  QRIZ
//
//  Created by 김세훈 on 5/1/25.
//

import Foundation

struct AppliedExamsRequest: Request {
    typealias Response = AppliedExamsResponse

    let accessToken: String
    let path = "/api/v1/applied"
    let method: HTTPMethod = .get

    var headers: HTTPHeader {
        [
            HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue,
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
}

struct AppliedExamsResponse: Decodable {
    let code: Int
    let msg: String
    let data: ExamInfo

    struct ExamInfo: Decodable {
        let examName: String
        let period: String
        let examDate: String
    }
}
