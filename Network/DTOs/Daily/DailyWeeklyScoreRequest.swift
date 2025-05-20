//
//  DailyWeeklyScoreRequest.swift
//  QRIZ
//
//  Created by 이창현 on 5/17/25.
//

import Foundation

struct DailyWeeklyScoreRequest: Request {
    
    // MARK: - Properties
    typealias Response = DailyWeeklyScoreResponse
    
    let method: HTTPMethod = .get
    private let accessToken: String
    private let day: Int
    
    var path: String {
        "/api/v1/daily/weekly-reviews/\(day)"
    }
    
    var headers: HTTPHeader {
        [
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
    
    // MARK: - Initializers
    init(accessToken: String, day: Int) {
        self.accessToken = accessToken
        self.day = day
    }
}

struct DailyWeeklyScoreResponse: Decodable {
    let code: Int
    let msg: String
    let data: DataInfo
    
    struct DataInfo: Decodable {
        let subjects: [SubjectInfo]
        let totalScore: CGFloat
        
        struct SubjectInfo: Decodable {
            let title: String
            let totalScore: CGFloat
            let majorItems: [MajorItemInfo]
            
            struct MajorItemInfo: Decodable {
                let majorItem: String
                let score: CGFloat
                let subItemScores: [SubItemInfo]
                
            }
        }
    }
}

struct SubItemInfo: Decodable {
    let subItem: String
    let score: CGFloat
}
