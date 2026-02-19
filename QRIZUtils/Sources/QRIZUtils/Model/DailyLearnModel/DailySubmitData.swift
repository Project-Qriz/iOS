//
//  DailyTestSubmitData.swift
//  QRIZ
//
//  Created by 이창현 on 4/29/25.
//

import Foundation

public struct DailySubmitData: Codable {
    public var question: SubmitQuestionData
    public var questionNum: Int
    public var optionId: Int?
    public var timeSpent: Int

    public init(question: SubmitQuestionData, questionNum: Int, optionId: Int?, timeSpent: Int) {
        self.question = question
        self.questionNum = questionNum
        self.optionId = optionId
        self.timeSpent = timeSpent
    }
}
