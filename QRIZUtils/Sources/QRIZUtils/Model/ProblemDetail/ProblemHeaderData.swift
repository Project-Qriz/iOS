//
//  ProblemHeaderData.swift
//  QRIZ
//
//  Created by Claude on 12/30/25.
//

import Foundation

public struct ProblemHeaderData {
    public let isCorrect: Bool             // 정답 여부
    public let examTitle: String           // "2023년도 모의고사"
    public let subject: String             // "1과목"
    public let questionNumber: Int         // 5
    public let tags: [String]              // ["엔터티", "식별자"]

    public init(isCorrect: Bool, examTitle: String, subject: String, questionNumber: Int, tags: [String]) {
        self.isCorrect = isCorrect
        self.examTitle = examTitle
        self.subject = subject
        self.questionNumber = questionNumber
        self.tags = tags
    }
}
