//
//  HomeState.swift
//  QRIZUtils
//
//  Created by 김세훈 on 5/27/25.
//

public struct HomeState: Equatable, Sendable {
    public var userName: String
    public var examStatus: ExamStatus
    public var entryState: EntryCardState
    public var dailyPlans: [DailyPlanEntity]
    public var selectedIndex: Int
    public var recommendationKind: RecommendationKind = .unknown
    public var weeklyConcepts: [WeeklyConcept] = []

    public init(
        userName: String,
        examStatus: ExamStatus,
        entryState: EntryCardState,
        dailyPlans: [DailyPlanEntity],
        selectedIndex: Int,
        recommendationKind: RecommendationKind = .unknown,
        weeklyConcepts: [WeeklyConcept] = []
    ) {
        self.userName = userName
        self.examStatus = examStatus
        self.entryState = entryState
        self.dailyPlans = dailyPlans
        self.selectedIndex = selectedIndex
        self.recommendationKind = recommendationKind
        self.weeklyConcepts = weeklyConcepts
    }
}
