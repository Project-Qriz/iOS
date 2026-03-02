//
//  HomeTypes.swift
//  QRIZUtils
//
//  Created by Claude on 2/16/26.
//

public enum ExamStatus: Equatable, Hashable, Sendable {
    case none
    case expired(detail: ExamDetail)
    case registered(dDay: Int, detail: ExamDetail)
}

public struct ExamDetail: Equatable, Hashable, Sendable {
    public let examDateText: String
    public let examName: String
    public let applyPeriod: String

    public init(examDateText: String, examName: String, applyPeriod: String) {
        self.examDateText = examDateText
        self.examName = examName
        self.applyPeriod = applyPeriod
    }
}

public enum EntryCardState: Equatable, Hashable, Sendable {
    case preview
    case mock
}

public struct WeeklyConcept: Equatable, Hashable, Sendable {
    public let id: Int
    public let title: String
    public let subjectCount: Int
    public let importance: Importance

    public var chapter: Chapter? { Chapter.from(concept: title) }
    public var conceptItem: ConceptItem? {
        chapter?.conceptItems.first { $0.title == title }
    }

    public init(id: Int, title: String, subjectCount: Int, importance: Importance) {
        self.id = id
        self.title = title
        self.subjectCount = subjectCount
        self.importance = importance
    }
}

public enum Importance: String, Decodable, Sendable {
    case high = "상"
    case medium = "중"
    case low = "하"

    public var text: String { "출제율 \(rawValue)" }
}

public enum RecommendationKind: String, Decodable, Sendable {
    case weeklyCustom = "주간 맞춤 개념"
    case weeklyRecommendation = "주간 추천 개념"
    case previewIncomplete = "프리뷰 테스트 미완료"
    case unknown = ""
}
