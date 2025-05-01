//
//  DailyTestSubmitData.swift
//  QRIZ
//
//  Created by 이창현 on 4/29/25.
//

import Foundation

struct DailySubmitData: Codable {
    var question: SubmitQuestionData
    var questionNum: Int
    var optionId: Int
    var timeSpent: Int
}
