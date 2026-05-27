//
//  DailyDetailAndStatusRequest.swift
//  QRIZ
//
//  Created by 이창현 on 4/29/25.
//

public struct DailyDetailAndStatusRequest: Request, Sendable {
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
    
    public init(accessToken: String, dayNumber: Int) {
        self.accessToken = accessToken
        self.dayNumber = dayNumber
    }
}

public struct DailyDetailAndStatusResponse: Decodable, Sendable {
    public let code: Int
    public let msg: String
    public let data: DataInfo

    public init(code: Int, msg: String, data: DataInfo) {
        self.code = code
        self.msg = msg
        self.data = data
    }

    public struct DataInfo: Decodable, Sendable {
        public let dayNumber: String
        public let skills: [SkillInfo]
        public let status: StatusInfo

        public init(dayNumber: String, skills: [SkillInfo], status: StatusInfo) {
            self.dayNumber = dayNumber
            self.skills = skills
            self.status = status
        }

        public struct SkillInfo: Decodable, Sendable {
            public let id: Int
            public let keyConcepts: String
            public let description: String

            public init(id: Int, keyConcepts: String, description: String) {
                self.id = id
                self.keyConcepts = keyConcepts
                self.description = description
            }
        }

        public struct StatusInfo: Decodable, Sendable {
            public let attemptCount: Int
            public let passed: Bool
            public let retestEligible: Bool
            public let totalScore: Double
            public let available: Bool

            public init(attemptCount: Int, passed: Bool, retestEligible: Bool, totalScore: Double, available: Bool) {
                self.attemptCount = attemptCount
                self.passed = passed
                self.retestEligible = retestEligible
                self.totalScore = totalScore
                self.available = available
            }
        }
    }
}
