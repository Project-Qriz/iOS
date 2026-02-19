//
//  WeeklyRecommendRequest.swift
//  QRIZ
//
//  Created by 김세훈 on 7/20/25.
//

import Foundation
import QRIZUtils

public struct WeeklyRecommendRequest: Request , Sendable {
    public typealias Response = WeeklyRecommendResponse
    
    public let accessToken: String
    public let path = "/api/v1/recommend/weekly"
    public let method: HTTPMethod = .get
    
    public var headers: HTTPHeader {
        [
            HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue,
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
}

public struct WeeklyRecommendResponse: Decodable , Sendable {
    public let code: Int
    public let msg: String
    public let data: RecommendData
}

public struct RecommendData: Decodable , Sendable {
    public let recommendationType: String
    public let recommendations: [Item]
    
    public struct Item: Decodable , Sendable {
        public let skillId: Int
        public let keyConcepts: String
        public let description: String
        public let importanceLevel: String
        public let frequency: Int
        public let incorrectRate: Double?
    }
}

extension RecommendData.Item {
    public func toConcept(using subject: Subject) -> WeeklyConcept {
        WeeklyConcept(
            id: skillId,
            title: keyConcepts,
            subjectCount: subject == .one ? 1 : 2,
            importance: Importance(rawValue: importanceLevel) ?? .medium
        )
    }
}


extension RecommendData {
    public func toKindAndConcepts() -> (RecommendationKind, [WeeklyConcept]) {
        let kind = RecommendationKind(rawValue: recommendationType) ?? .unknown

        let concepts = recommendations.compactMap { item -> WeeklyConcept? in
            guard
                let chapter = Chapter.from(concept: item.keyConcepts),
                let subject = Subject.from(chapter: chapter)
            else { return nil }
            return item.toConcept(using: subject)
        }
        return (kind, concepts)
    }
}
