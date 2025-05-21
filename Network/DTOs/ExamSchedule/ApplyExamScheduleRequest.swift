//
//  ApplyExamScheduleRequest.swift
//  QRIZ
//
//  Created by 김세훈 on 5/10/25.
//

import Foundation

struct ApplyExamScheduleRequest: Request {
    typealias Response = ApplyExamScheduleResponse
    
    private let accessToken: String
    private let applyId: Int
    let path = "/api/v1/applications"
    let method: HTTPMethod = .post
    
    var headers: HTTPHeader {
        [
            HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue,
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
    
    var body: Encodable? {
        [
            "applyId": applyId
        ]
    }
    
    init(accessToken: String, applyId: Int) {
        self.accessToken = accessToken
        self.applyId = applyId
    }
}

struct ApplyExamScheduleResponse: Decodable {
    let code: Int
    let msg: String
    let data: ExamInfo?

    struct ExamInfo: Decodable {
        let examName: String
        let period: String
        let examDate: String
        let releaseDate: String
    }
}
