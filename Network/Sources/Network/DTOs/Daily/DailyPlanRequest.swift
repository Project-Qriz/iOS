//
//  DailyPlanRequest.swift
//  QRIZ
//
//  Created by 김세훈 on 6/24/25.
//

import Foundation

public struct DailyPlanRequest: Request , Sendable {
    public typealias Response = DailyPlanResponse

    public let accessToken: String
    public let path = "/api/v1/daily/plan"
    public let method: HTTPMethod = .get

    public var headers: HTTPHeader {
        [
            HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue,
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
}

public struct DailyPlanResponse: Decodable , Sendable {
    public let code: Int
    public let msg: String
    public let data: [DailyPlan]?
}

public struct DailyPlan: Equatable, Hashable, Decodable , Sendable {
    public let id: Int
    public let dayNumber: String
    public let completed: Bool
    public let planDate: String
    public let completionDate: String?
    public let plannedSkills: [PlannedSkill]
    public let reviewDay: Bool
    public let comprehensiveReviewDay: Bool
    public let today: Bool
    public let lastDay: Bool
}

public struct PlannedSkill: Equatable, Hashable, Decodable , Sendable {
    public let id: Int
    public let type: String
    public let keyConcept: String
    public let description: String

    public init(id: Int, type: String, keyConcept: String, description: String) {
        self.id = id
        self.type = type
        self.keyConcept = keyConcept
        self.description = description
    }
}
