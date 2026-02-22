//
//  ResultGradeListData.swift
//  QRIZUtils
//
//  Created by 이창현 on 4/18/25.
//

import Combine

public final class ResultGradeListData: ObservableObject {
    @Published public var gradeResultList: [GradeResult] = []

    public init() {}
}

public struct GradeResult: Identifiable {
    public var id: Int  // UI 표시용 순번
    public var questionId: Int  // 실제 API questionId
    public var skillName: String
    public var question: String
    public var correction: Bool

    public init(id: Int, questionId: Int, skillName: String, question: String, correction: Bool) {
        self.id = id
        self.questionId = questionId
        self.skillName = skillName
        self.question = question
        self.correction = correction
    }
}
