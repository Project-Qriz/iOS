//
//  DailyDetailAndStatusRequest.swift
//  QRIZ
//
//  Created by 이창현 on 4/29/25.
//

import Foundation

struct DailyDetailAndStatusRequest: Request {
    
    // MARK: - Properties
    typealias Response = DailyDetailAndStatusResponse
    private let accessToken: String
    
    var path: String {
        "/api/v1/daily/detail-status/\(dayNumber)"
    }
    var method: HTTPMethod = .get
    var dayNumber: Int
    
    var headers: HTTPHeader {
        return [
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
    
    // MARK: - Initializers
    init(accessToken: String, dayNumber: Int) {
        self.accessToken = accessToken
        self.dayNumber = dayNumber
    }
}

struct DailyDetailAndStatusResponse: Decodable {
    let code: Int
    let msg: String
    let data: dataInfo
    
    struct dataInfo: Decodable {
        let dayNumber: String
        let skills: [SkillInfo]
        let status: StatusInfo
        
        struct SkillInfo: Decodable {
            let id: Int
            let keyConcepts: String
            let description: String
        }
        
        struct StatusInfo: Decodable {
            let attemptCount: Int
            let passed: Bool
            let retestEligible: Bool
            let totalScore: Double
            let available: Bool
        }
    }
    
}
