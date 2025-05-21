//
//  ExamListRequest.swift
//  QRIZ
//
//  Created by 김세훈 on 5/5/25.
//

import Foundation

struct ExamListRequest: Request {
    typealias Response = ExamListResponse

    let accessToken: String
    let path = "/api/v1/applications"
    let method: HTTPMethod = .get

    var headers: HTTPHeader {
        [
            HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue,
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
}

struct ExamListResponse: Decodable {
    let code: Int
    let msg: String
    let data: ExamListData
}

struct ExamListData: Decodable {
    let registeredApplicationId: Int?
    let registeredUserApplyId: Int?
    let applications: [ExamInfo]
}

struct ExamInfo: Decodable {
    let applicationId: Int
    let userApplyId: Int?
    let examName: String
    let period: String
    let examDate: String
    let releaseDate: String
}

extension ExamListResponse {
    func convert() -> [ExamRowState] {
        let todayMD = Date.todayMonthDay
        
        return data.applications.map { info in
            let examMD = monthDay(from: info.examDate) ?? .max
            return ExamRowState(
                id:         info.applicationId,
                examName:   info.examName,
                periodText: "접수기간: \(info.period)",
                dateText:   "시험일: \(info.examDate)",
                isSelected: info.applicationId == data.registeredApplicationId,
                isExpired:  examMD < todayMD
            )
        }
    }
}
