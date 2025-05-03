//
//  TestSubmitData.swift
//  QRIZ
//
//  Created by 이창현 on 4/26/25.
//

import Foundation

struct TestSubmitData: Codable {
    var question: SubmitQuestionData
    var questionNum: Int
    var optionId: Int?
}

struct SubmitQuestionData: Codable {
    var questionId: Int
    var category: Int
}
