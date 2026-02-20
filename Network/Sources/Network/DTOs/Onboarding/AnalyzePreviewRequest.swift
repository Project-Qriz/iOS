//
//  AnalyzePreviewRequest.swift
//  QRIZ
//
//  Created by ch on 4/25/25.
//

import Foundation

public struct AnalyzePreviewRequest: Request, Sendable {
    public typealias Response = AnalyzePreviewResponse

    public let path = "/api/v1/preview/analyze"
    public let method: HTTPMethod = .get
    private let accessToken: String
    
    public var headers: HTTPHeader {
        [
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
    
    public init(accessToken: String) {
        self.accessToken = accessToken
    }
}

public struct AnalyzePreviewResponse: Decodable, Sendable {
    public let code: Int
    public let msg: String
    public let data: DataInfo
    
    public struct DataInfo: Decodable, Sendable {
        public let estimatedScore: Double
        public let scoreBreakdown: ScoreBreakdown
        public let weakAreaAnalysis: WeakAreaAnalysis
        public let topConceptsToImprove: [String]
    }
    
    public struct ScoreBreakdown: Decodable, Sendable {
        public let totalScore: Int
        public let part1Score: Int
        public let part2Score: Int
    }
    
    public struct WeakAreaAnalysis: Decodable, Sendable {
        public let totalQuestions: Int
        public let weakAreas: [WeakArea]
    }
    
    public struct WeakArea: Decodable, Sendable {
        public let topic: String
        public let incorrectCount: Int
    }
}
