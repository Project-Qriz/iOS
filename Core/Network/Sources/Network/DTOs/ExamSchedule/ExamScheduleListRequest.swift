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

    public let path = "/api/v1/applications"
    public let method: HTTPMethod = .get
    private let accessToken: String

    public var headers: HTTPHeader {
        [
            HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue,
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }

    public init(accessToken: String) {
        self.accessToken = accessToken
    }
}

public struct ExamScheduleListResponse: Decodable, Sendable {
    public let code: Int
    public let msg: String
    public let data: ExamListData

    public init(code: Int, msg: String, data: ExamListData) {
        self.code = code
        self.msg = msg
        self.data = data
    }
}

public struct ExamListData: Decodable, Sendable {
    public let registeredApplicationId: Int?
    public let registeredUserApplyId: Int?
    public let applications: [ExamInfo]

    public init(registeredApplicationId: Int?, registeredUserApplyId: Int?, applications: [ExamInfo]) {
        self.registeredApplicationId = registeredApplicationId
        self.registeredUserApplyId = registeredUserApplyId
        self.applications = applications
    }
}

public struct ExamInfo: Decodable, Sendable {
    public let applicationId: Int
    public let userApplyId: Int?
    public let examName: String
    public let period: String
    public let examDate: String
    public let releaseDate: String

    public init(applicationId: Int, userApplyId: Int?, examName: String, period: String, examDate: String, releaseDate: String) {
        self.applicationId = applicationId
        self.userApplyId = userApplyId
        self.examName = examName
        self.period = period
        self.examDate = examDate
        self.releaseDate = releaseDate
    }
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
