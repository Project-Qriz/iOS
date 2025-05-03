//
//  ExamListRequest.swift
//  QRIZ
//
//  Created by ch on 5/2/25.
//

import Foundation

struct ExamListRequest: Request {
    
    // MARK: - Properties
    typealias Response = ExamListResponse

    let path = "/api/v1/exam/session-list"
    let method: HTTPMethod = .get
    private let accessToken: String
    private let examStatus: ExamStatus?
    private let isAscSortedByDate: Bool

    var query: QueryItems {
        var dic: [String: String] = [:]

        if isAscSortedByDate { dic["sort"] = "asc" }

        if let examStatus = examStatus { dic["status"] = examStatus.rawValue }

        return dic
    }
    
    var headers: HTTPHeader {
        [
            HTTPHeaderField.accessToken.rawValue: accessToken
        ]
    }
    
    // MARK: - Initializers
    init(accessToken: String, examStatus: ExamStatus? = nil, isAscSortedByDate: Bool = false) {
        self.accessToken = accessToken
        self.examStatus = examStatus
        self.isAscSortedByDate = isAscSortedByDate
    }
}

struct ExamListResponse: Decodable {
    let code: Int
    let msg: String
    let data: [DataInfo]
    
    struct DataInfo: Decodable {
        let completed: Bool
        let session: String
        let totalScore: CGFloat?
    }
}
