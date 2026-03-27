//
//  DailyPlanEntity.swift
//  QRIZUtils
//
//  Created by 김세훈 on 2/22/26.
//

public struct DailyPlanEntity: Equatable, Hashable, Sendable {
    public let id: Int
    public let dayNumber: String
    public let completed: Bool
    public let planDate: String
    public let completionDate: String?
    public let plannedSkills: [PlannedSkillEntity]
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
        plannedSkills: [PlannedSkillEntity],
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
}

public struct PlannedSkillEntity: Equatable, Hashable, Sendable {
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
