//
//  DailyResultDetailRequest.swift
//  QRIZ
//
//  Created by Claude on 1/2/26.
//

import Foundation

struct DailyResultDetailRequest: Request {
    typealias Response = DailyResultDetailResponse

    let method: HTTPMethod = .get
    private let accessToken: String
    private let dayNumber: Int
    private let questionId: Int

    var path: String {
        "/api/v1/daily/result/\(dayNumber)/\(questionId)"
    }

    var headers: HTTPHeader {
        [
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }

    init(accessToken: String, dayNumber: Int, questionId: Int) {
        self.accessToken = accessToken
        self.dayNumber = dayNumber
        self.questionId = questionId
    }
}


struct DailyResultDetailResponse: Decodable {
    let code: Int
    let msg: String
    let data: DailyResultDetail
}

struct DailyResultDetail: Decodable {
    let skillName: String
    let questionText: String
    let questionNum: Int
    let description: String?
    let option1: String
    let option2: String
    let option3: String
    let option4: String
    let answer: Int
    let solution: String
    let checked: Int?
    let correction: Bool
    let testInfo: String
    let skillId: Int
    let title: String
    let keyConcepts: String
}
