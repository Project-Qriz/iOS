//
//  AnalyzePreviewRequest.swift
//  QRIZ
//
//  Created by ch on 4/25/25.
//

import Foundation

struct AnalyzePreviewRequest: Request {
    
    // MARK: - Properties
    typealias Response = AnalyzePreviewResponse
    private let accessToken: String
    
    var path = "/api/v1/preview/analyze"
    var method: HTTPMethod = .get
    
    var headers: HTTPHeader {
        [
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
    
    // MARK: - Initializers
    init(accessToken: String) {
        self.accessToken = accessToken
    }
}

struct AnalyzePreviewResponse: Decodable {
    let code: Int
    let msg: String
    let data: DataInfo
    
    struct DataInfo: Decodable {
        let estimatedScore: CGFloat
        let scoreBreakdown: ScoreBreakdown
        let weakAreaAnalysis: WeakAreaAnalysis
        let topConceptsToImprove: [String]
    }
    
    struct ScoreBreakdown: Decodable {
        let totalScore: Int
        let part1Score: Int
        let part2Score: Int
    }
    
    struct WeakAreaAnalysis: Decodable {
        let totalQuestions: Int
        let weakAreas: [WeakArea]
    }
    
    struct WeakArea: Decodable {
        let topic: String
        let incorrectCount: Int
    }
}
