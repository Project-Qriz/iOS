//
//  DailyPlanRequest.swift
//  QRIZ
//
//  Created by 김세훈 on 6/24/25.
//

import Foundation

struct DailyPlanRequest: Request {
    typealias Response = DailyPlanResponse

    let accessToken: String
    let path = "/api/v1/daily/plan"
    let method: HTTPMethod = .get

    var headers: HTTPHeader {
        [
            HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue,
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
}

struct DailyPlanResponse: Decodable {
    let code: Int
    let msg: String
    let data: [DailyPlan]
}

struct DailyPlan: Equatable, Hashable, Decodable {
    let id: Int
    let dayNumber: String
    let completed: Bool
    let planDate: String
    let completionDate: String?
    let plannedSkills: [PlannedSkill]
    let reviewDay: Bool
    let comprehensiveReviewDay: Bool
    let today: Bool
    let lastDay: Bool
}

struct PlannedSkill: Equatable, Hashable, Decodable {
    let id: Int
    let type: String
    let keyConcept: String
    let description: String
}
