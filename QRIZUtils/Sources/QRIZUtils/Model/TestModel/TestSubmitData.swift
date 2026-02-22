//
//  TestSubmitData.swift
//  QRIZUtils
//
//  Created by 이창현 on 4/26/25.
//

public struct TestSubmitData: Codable, Sendable {
    public var question: SubmitQuestionData
    public var questionNum: Int
    public var optionId: Int?

    public init(question: SubmitQuestionData, questionNum: Int, optionId: Int?) {
        self.question = question
        self.questionNum = questionNum
        self.optionId = optionId
    }
}

public struct SubmitQuestionData: Codable, Sendable {
    public var questionId: Int
    public var category: Int

    public init(questionId: Int, category: Int) {
        self.questionId = questionId
        self.category = category
    }
}
