//
//  StudySummary.swift
//  QRIZ
//
//  Created by 김세훈 on 4/25/25.
//

import QRIZUtils

struct StudySummary: Equatable, Hashable {
    let id: Int
    let dailyPlans: [DailyPlanEntity]

    static let locked = StudySummary(id: -1, dailyPlans: [])
}
