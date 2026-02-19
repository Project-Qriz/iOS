//
//  HomeState.swift
//  QRIZ
//
//  Created by 김세훈 on 5/27/25.
//

import Foundation
import QRIZUtils

struct HomeState: Equatable {
    var userName: String
    var examStatus: ExamStatus
    var entryState: EntryCardState
    var dailyPlans: [DailyPlan]
    var selectedIndex: Int
    var recommendationKind: RecommendationKind = .unknown
    var weeklyConcepts: [WeeklyConcept] = []
}
