//
//  ExamListRequest.swift
//  QRIZ
//
//  Created by ch on 5/2/25.
//

import QRIZUtils

public struct ExamListRequest: Request, Sendable {
    
    // MARK: - Properties
    public typealias Response = ExamListResponse

    public let path = "/api/v1/exam/session-list"
    public let method: HTTPMethod = .get
    private let accessToken: String
    private let filterType: ExamListFilterType

    public var query: QueryItems {
        return filterType.queryParameter
    }
    
    public var headers: HTTPHeader {
        [
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
    
    // MARK: - Initializers
    public init(accessToken: String, filterType: ExamListFilterType) {
        self.accessToken = accessToken
        self.filterType = filterType
    }
}

public struct ExamListResponse: Decodable, Sendable {
    public let code: Int
    public let msg: String
    public let data: [ExamListDataInfo]
}

public struct ExamListDataInfo: Decodable, Sendable {
    public let completed: Bool
    public let session: String
    public let totalScore: Double?
}
