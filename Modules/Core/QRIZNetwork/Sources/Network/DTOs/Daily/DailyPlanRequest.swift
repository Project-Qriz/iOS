//
//  DailyPlanRequest.swift
//  QRIZ
//
//  Created by 김세훈 on 6/24/25.
//

import QRIZUtils

public struct DailyPlanRequest: Request, Sendable {
    public typealias Response = DailyPlanResponse

    public let path = "/api/v1/daily/plan"
    public let method: HTTPMethod = .get
    private let accessToken: String

    public var headers: HTTPHeader {
        [
            HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue,
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }

    public init(accessToken: String) {
        self.accessToken = accessToken
    }
}

public struct DailyPlanResponse: Decodable, Sendable {
    public let code: Int
    public let msg: String
    public let data: [DailyPlan]?

    public init(code: Int, msg: String, data: [DailyPlan]?) {
        self.code = code
        self.msg = msg
        self.data = data
    }
}

public struct DailyPlan: Equatable, Hashable, Decodable, Sendable {
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

    public init(
        id: Int,
        dayNumber: String,
        completed: Bool,
        planDate: String,
        completionDate: String?,
        plannedSkills: [PlannedSkill],
        reviewDay: Bool,
        comprehensiveReviewDay: Bool,
        today: Bool,
        lastDay: Bool
    ) {
        self.id = id
        self.dayNumber = dayNumber
        self.completed = completed
        self.planDate = planDate
        self.completionDate = completionDate
        self.plannedSkills = plannedSkills
        self.reviewDay = reviewDay
        self.comprehensiveReviewDay = comprehensiveReviewDay
        self.today = today
        self.lastDay = lastDay
    }

    public func toEntity() -> DailyPlanEntity {
        DailyPlanEntity(
            id: id,
            dayNumber: dayNumber,
            completed: completed,
            planDate: planDate,
            completionDate: completionDate,
            plannedSkills: plannedSkills.map { $0.toEntity() },
            reviewDay: reviewDay,
            comprehensiveReviewDay: comprehensiveReviewDay,
            today: today,
            lastDay: lastDay
        )
    }
}

public struct PlannedSkill: Equatable, Hashable, Decodable, Sendable {
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

    public func toEntity() -> PlannedSkillEntity {
        PlannedSkillEntity(
            id: id,
            type: type,
            keyConcept: keyConcept,
            description: description
        )
    }
}
