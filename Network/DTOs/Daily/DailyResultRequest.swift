//
//  DailyResultRequest.swift
//  QRIZ
//
//  Created by 이창현 on 5/1/25.
//

import Foundation

struct DailyResultRequest: Request {
    
    // MARK: - Properties
    typealias Response = DailyResultResponse
    private let accessToken: String
    
    var path: String {
        "/api/v1/subject-details/\(dayNumber)"
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

struct DailyResultResponse: Decodable {
    let code: Int
    let msg: String
    let dataInfo: DataInfo
    
    struct DataInfo: Decodable {
        let dayNumber: String
        let passed: Bool
        let userDailyInfoList: [UserDailyInfo]
        let subjectResultsList: [SubjectResult]

        struct UserDailyInfo: Decodable {
            let skillId: Int
            let title: String
            let totalScore: CGFloat
            let items: [Item]

            struct Item: Decodable {
                let skillId: Int
                let type: String
                let score: CGFloat
            }
        }
        
        struct SubjectResult: Decodable {
            let skillName: String
            let question: String
            let correction: Bool
        }
    }
}
