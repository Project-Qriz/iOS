//
//  ExamResultDetailRequest.swift
//  QRIZ
//
//  Created by Claude on 2/10/26.
//

import Foundation

/// 모의고사 문제 상세 조회
/// GET /api/v1/exam/result/{examId}/{questionId}
public struct ExamResultDetailRequest: Request , Sendable {
    public typealias Response = ExamResultDetailResponse

    public let method: HTTPMethod = .get
    private let accessToken: String
    private let examId: Int
    private let questionId: Int

    public var path: String {
        "/api/v1/exam/result/\(examId)/\(questionId)"
    }

    public var headers: HTTPHeader {
        [
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }

    public init(accessToken: String, examId: Int, questionId: Int) {
        self.accessToken = accessToken
        self.examId = examId
        self.questionId = questionId
    }
}

public struct ExamResultDetailResponse: Decodable , Sendable {
    public let code: Int
    public let msg: String
    public let data: DailyResultDetail
}
