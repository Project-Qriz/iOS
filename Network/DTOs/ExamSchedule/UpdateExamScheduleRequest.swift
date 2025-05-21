//
//  UpdateExamScheduleRequest.swift
//  QRIZ
//
//  Created by 김세훈 on 5/11/25.
//

import Foundation

struct UpdateExamScheduleRequest: Request {
    typealias Response = UpdateExamScheduleResponse
    
    private let accessToken: String
    private let userApplyId: Int
    private let newApplyId: Int
    
    var path: String { "/api/v1/applications/\(userApplyId)" }
    let method: HTTPMethod = .patch
    
    var headers: HTTPHeader {
        [
            HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue,
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
    
    var body: Encodable? {
        [
            "newApplyId": newApplyId
        ]
    }
    
    init(accessToken: String, userApplyId: Int, newApplyId: Int) {
        self.accessToken = accessToken
        self.userApplyId = userApplyId
        self.newApplyId = newApplyId
    }
}

struct UpdateExamScheduleResponse: Decodable {
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
