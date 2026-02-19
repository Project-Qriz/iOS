//
//  DailyDetailAndStatusRequest.swift
//  QRIZ
//
//  Created by 이창현 on 4/29/25.
//

import Foundation

public struct DailyDetailAndStatusRequest: Request , Sendable {
    
    // MARK: - Properties
    public typealias Response = DailyDetailAndStatusResponse
    
    public let method: HTTPMethod = .get
    private let accessToken: String
    private let dayNumber: Int

    public var path: String {
        "/api/v1/daily/detail-status/\(dayNumber)"
    }
    
    public var headers: HTTPHeader {
        [
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
    
    // MARK: - Initializers
    public init(accessToken: String, dayNumber: Int) {
        self.accessToken = accessToken
        self.dayNumber = dayNumber
    }
}

public struct DailyDetailAndStatusResponse: Decodable , Sendable {
    public let code: Int
    public let msg: String
    public let data: DataInfo
    
    public struct DataInfo: Decodable , Sendable {
        public let dayNumber: String
        public let skills: [SkillInfo]
        public let status: StatusInfo
        
        public struct SkillInfo: Decodable , Sendable {
            public let id: Int
            public let keyConcepts: String
            public let description: String
        }
        
        public struct StatusInfo: Decodable , Sendable {
            public let attemptCount: Int
            public let passed: Bool
            public let retestEligible: Bool
            public let totalScore: Double
            public let available: Bool
        }
    }
    
}
