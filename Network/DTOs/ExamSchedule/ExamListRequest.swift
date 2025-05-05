//
//  ExamListRequest.swift
//  QRIZ
//
//  Created by 김세훈 on 5/5/25.
//

import Foundation

struct ExamListRequest: Request {
    typealias Response = ExamListResponse

    let accessToken: String
    let path = "/api/v1/application-list"
    let method: HTTPMethod = .get

    var headers: HTTPHeader {
        [
            HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue,
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
}

struct ExamListResponse: Decodable {
    let code: Int
    let msg: String
    let data: ExamListData
}

struct ExamListData: Decodable {
    let registeredApplicationId: Int?
    let applications: [ExamInfo]
}

struct ExamInfo: Decodable {
    let applyId: Int
    let examName: String
    let period: String
    let examDate: String
    let releaseDate: String
}
