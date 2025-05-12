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
    private let filterType: ExamListFilterType

    var query: QueryItems {
        switch filterType {
        case .completed:
            return ["status": "completed"]
        case .incomplete:
            return ["status": "incomplete"]
        case .sortByDate:
            return ["sort": "asc"]
        default:
            return [:]
        }
    }
    
    var headers: HTTPHeader {
        [
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
    
    // MARK: - Initializers
    init(accessToken: String, filterType: ExamListFilterType) {
        self.accessToken = accessToken
        self.filterType = filterType
    }
}

struct ExamListResponse: Decodable {
    let code: Int
    let msg: String
    let data: [ExamListDataInfo]
}

struct ExamListDataInfo: Decodable {
    let completed: Bool
    let session: String
    let totalScore: CGFloat?
}
