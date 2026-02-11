//
//  ExamResultDetailRequest.swift
//  QRIZ
//
//  Created by Claude on 2/10/26.
//

import Foundation

/// 모의고사 문제 상세 조회
/// GET /api/v1/exam/result/{examId}/{questionId}
struct ExamResultDetailRequest: Request {
    typealias Response = ExamResultDetailResponse

    let method: HTTPMethod = .get
    private let accessToken: String
    private let examId: Int
    private let questionId: Int

    var path: String {
        "/api/v1/exam/result/\(examId)/\(questionId)"
    }

    var headers: HTTPHeader {
        [
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }

    init(accessToken: String, examId: Int, questionId: Int) {
        self.accessToken = accessToken
        self.examId = examId
        self.questionId = questionId
    }
}

struct ExamResultDetailResponse: Decodable {
    let code: Int
    let msg: String
    let data: DailyResultDetail
}
