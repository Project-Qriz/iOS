//
//  HomeState.swift
//  QRIZ
//
//  Created by 김세훈 on 5/27/25.
//

import Foundation

struct HomeState: Equatable {
    var userName: String
    var examStatus: ExamStatus
    var entryState: EntryCardState
    var dailyPlans: [DailyPlan]
    var selectedIndex: Int
    var recommendationKind: RecommendationKind = .unknown
    var weeklyConcepts: [WeeklyConcept] = []
}

enum ExamStatus: Equatable, Hashable {
    case none
    case expired(detail: ExamDetail)
    case registered(dDay: Int, detail: ExamDetail)
}

struct ExamDetail: Equatable, Hashable {
    let examDateText: String
    let examName: String
    let applyPeriod: String
}

enum EntryCardState: Equatable, Hashable {
    case preview
    case mock
}

struct WeeklyConcept: Equatable, Hashable {
    let id: Int
    let title: String
    let subjectCount: Int
    let importance: Importance
    
    var chapter: Chapter? { Chapter.from(concept: title) }
    var conceptItem: ConceptItem? {
        chapter?.conceptItems.first { $0.title == title }
    }
}

enum Importance: String, Decodable {
    case high = "상"
    case medium = "중"
    case low = "하"
    
    var text: String { "출제율 \(rawValue)" }
}

enum RecommendationKind: String, Decodable {
    case weeklyCustom = "주간 맞춤 개념"
    case previewIncomplete = "프리뷰 테스트 미완료"
    case unknown = ""
}
