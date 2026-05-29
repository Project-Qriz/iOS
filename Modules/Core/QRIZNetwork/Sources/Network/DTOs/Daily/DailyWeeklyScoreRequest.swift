//
//  DailyWeeklyScoreRequest.swift
//  QRIZ
//
//  Created by 이창현 on 5/17/25.
//

import Foundation
import QRIZUtils

public struct DailyWeeklyScoreRequest: Request, Sendable {
    public typealias Response = DailyWeeklyScoreResponse
    
    public let method: HTTPMethod = .get
    private let accessToken: String
    private let day: Int
    
    public var path: String {
        "/api/v1/daily/weekly-reviews/\(day)"
    }
    
    public var headers: HTTPHeader {
        [
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
    
    public init(accessToken: String, day: Int) {
        self.accessToken = accessToken
        self.day = day
    }
}

public struct DailyWeeklyScoreResponse: Decodable, Sendable {
    public let code: Int
    public let msg: String
    public let data: DataInfo

    public init(code: Int, msg: String, data: DataInfo) {
        self.code = code
        self.msg = msg
        self.data = data
    }

    public struct DataInfo: Decodable, Sendable {
        public let subjects: [SubjectInfo]
        public let totalScore: Double

        public init(subjects: [SubjectInfo], totalScore: Double) {
            self.subjects = subjects
            self.totalScore = totalScore
        }

        public struct SubjectInfo: Decodable, Sendable {
            public let title: String
            public let totalScore: Double
            public let majorItems: [MajorItemInfo]

            public init(title: String, totalScore: Double, majorItems: [MajorItemInfo]) {
                self.title = title
                self.totalScore = totalScore
                self.majorItems = majorItems
            }

            public struct MajorItemInfo: Decodable, Sendable {
                public let majorItem: String
                public let score: Double
                public let subItemScores: [SubItemInfo]

                public init(majorItem: String, score: Double, subItemScores: [SubItemInfo]) {
                    self.majorItem = majorItem
                    self.score = score
                    self.subItemScores = subItemScores
                }
            }
        }
    }
}

