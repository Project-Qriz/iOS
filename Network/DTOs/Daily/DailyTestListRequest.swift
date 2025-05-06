//
//  DailyTestListRequest.swift
//  QRIZ
//
//  Created by 이창현 on 4/29/25.
//

import Foundation

struct DailyTestListRequest: Request {
    
    // MARK: - Properties
    typealias Response = DailyTestListResponse
    
    let method: HTTPMethod = .get
    private let accessToken: String
    private let dayNumber: Int
    
    var path: String {
        "/api/v1/daily/get/\(dayNumber)"
    }

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

struct DailyTestListResponse: Decodable {
    let code: Int
    let msg: String
    let data: DataInfo?
    
    struct DataInfo: Decodable {
        let questionId: Int
        let skillId: Int
        let category: Int
        let question: String
        let description: String
        let options: [OptionInfo]
        let timeLimit: Int
        let difficulty: Int
        
        struct OptionInfo: Decodable {
            let id: Int
            let content: String
        }
    }
    
}
