//
//  ExamRowState.swift
//  QRIZ
//
//  Created by 김세훈 on 5/8/25.
//

import Foundation

public struct ExamRowState: Hashable {
    public let id: Int
    public let examName: String
    public let periodText: String
    public let dateText: String
    public let isSelected: Bool
    public let isExpired: Bool

    public init(id: Int, examName: String, periodText: String, dateText: String, isSelected: Bool, isExpired: Bool) {
        self.id = id
        self.examName = examName
        self.periodText = periodText
        self.dateText = dateText
        self.isSelected = isSelected
        self.isExpired = isExpired
    }
}
