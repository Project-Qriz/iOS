//
//  WeeklyRecommendRequest.swift
//  QRIZ
//
//  Created by 김세훈 on 7/20/25.
//

import Foundation

struct WeeklyRecommendRequest: Request {
    typealias Response = WeeklyRecommendResponse
    
    let accessToken: String
    let path = "/api/v1/recommend/weekly"
    let method: HTTPMethod = .get
    
    var headers: HTTPHeader {
        [
            HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue,
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
}

struct WeeklyRecommendResponse: Decodable {
    let code: Int
    let msg: String
    let data: RecommendData
}

struct RecommendData: Decodable {
    let recommendationType: String
    let recommendations: [Item]
    
    struct Item: Decodable {
        let skillId: Int
        let keyConcepts: String
        let description: String
        let importanceLevel: String
        let frequency: Int
        let incorrectRate: Double?
    }
}

extension RecommendData.Item {
    func toConcept(using subject: Subject) -> WeeklyConcept {
        WeeklyConcept(
            id: skillId,
            title: keyConcepts,
            subjectCount: subject == .one ? 1 : 2,
            importance: Importance(rawValue: importanceLevel) ?? .medium
        )
    }
}


extension RecommendData {
    func toKindAndConcepts() -> (RecommendationKind, [WeeklyConcept]) {
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
