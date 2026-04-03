//
//  DailyResultDetailEntity.swift
//  QRIZUtils
//
//  Created by 김세훈 on 2/22/26.
//

public struct DailyResultDetailEntity: Sendable {
    public let skillName: String
    public let questionText: String
    public let questionNum: Int
    public let description: String?
    public let option1: String
    public let option2: String
    public let option3: String
    public let option4: String
    public let answer: Int
    public let solution: String
    public let checked: Int?
    public let correction: Bool
    public let testInfo: String
    public let skillId: Int
    public let title: String
    public let keyConcepts: String

    public init(
        skillName: String,
        questionText: String,
        questionNum: Int,
        description: String?,
        option1: String,
        option2: String,
        option3: String,
        option4: String,
        answer: Int,
        solution: String,
        checked: Int?,
        correction: Bool,
        testInfo: String,
        skillId: Int,
        title: String,
        keyConcepts: String
    ) {
        self.skillName = skillName
        self.questionText = questionText
        self.questionNum = questionNum
        self.description = description
        self.option1 = option1
        self.option2 = option2
        self.option3 = option3
        self.option4 = option4
        self.answer = answer
        self.solution = solution
        self.checked = checked
        self.correction = correction
        self.testInfo = testInfo
        self.skillId = skillId
        self.title = title
        self.keyConcepts = keyConcepts
    }
}
