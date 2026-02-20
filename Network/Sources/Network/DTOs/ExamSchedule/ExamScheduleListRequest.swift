//
//  ExamScheduleListRequest.swift
//  QRIZ
//
//  Created by 김세훈 on 5/5/25.
//

import Foundation
import QRIZUtils

public struct ExamScheduleListRequest: Request, Sendable {
    public typealias Response = ExamScheduleListResponse

    public let accessToken: String
    public let path = "/api/v1/applications"
    public let method: HTTPMethod = .get

    public var headers: HTTPHeader {
        [
            HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue,
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
}

public struct ExamScheduleListResponse: Decodable, Sendable {
    public let code: Int
    public let msg: String
    public let data: ExamListData
}

public struct ExamListData: Decodable, Sendable {
    public let registeredApplicationId: Int?
    public let registeredUserApplyId: Int?
    public let applications: [ExamInfo]
}

public struct ExamInfo: Decodable, Sendable {
    public let applicationId: Int
    public let userApplyId: Int?
    public let examName: String
    public let period: String
    public let examDate: String
    public let releaseDate: String
}

extension ExamScheduleListResponse {
    public func convert() -> [ExamRowState] {
        let todayMD = Date.todayMonthDay
        
        return data.applications.map { info in
            let examMD = info.examDate.monthDay ?? .max
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
