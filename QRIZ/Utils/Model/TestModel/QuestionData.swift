//
//  QuestionList.swift
//  QRIZ
//
//  Created by ch on 12/21/24.
//

import Foundation

struct QuestionData {
    var question: String
    var option1: String
    var option2: String
    var option3: String
    var option4: String
    var timeLimit: Int

    var questionNumber: Int
    var selectedOption: Int? = nil
    
    func getOptionRawValue(option: Int) -> String {
        switch option {
        case 1:
            return option1
        case 2:
            return option2
        case 3:
            return option3
        case 4:
            return option4
        default:
            fatalError("QuestionData: selected option doesn't exist")
        }
    }
    
    static var sampleList: [QuestionData] = {
        var list: [QuestionData] = []
        for i in 0..<20 {
            var question: QuestionData
            if i % 3 == 0 {
                question = QuestionData(question: "다음 SQL 결과로 맞게 연결된 것을 고르시오.", option1: "ㄱ NULL ㄴ NULL ㄷ NULL ㄹ NULL", option2: "ㄱ NULl ㄴ NULl ㄷ NULl ㄹ NULl", option3: "ㄱ NUll ㄴ NUll ㄷ NUll ㄹ NUll", option4: "ㄱ null ㄴ null ㄷ null ㄹ null", timeLimit: 70, questionNumber: i + 1)
            } else if i % 3 == 1 {
                question = QuestionData(question: "다음 중 트랜잭션 모델링에서 '긴 트랜잭션(Long Transaction)'을 처리하는 방법으로 가장 적절한 것은?", option1: "트랜잭션을 더 작은 단위로 분할", option2: "트랜잭션의 타임아웃 시간을 늘림", option3: "모든 데이터를 메모리에 로드", option4: "트랜잭션의 격리 수준을 낮춤", timeLimit: 70, questionNumber: i + 1)
            } else {
                question = QuestionData(question: "다음 중 트랜잭션 모델링에서 '긴 트랜잭션(Long Transaction)'을 처리하는 방법으로 가장 적절한 것은?다음 중 트랜잭션 모델링에서 '긴 트랜잭션(Long Transaction)'을 처리하는 방법으로 가장 적절한 것은?다음 중 트랜잭션 모델링에서 '긴 트랜잭션(Long Transaction)'을 처리하는 방법으로 가장 적절한 것은?", option1: "트랜잭션을 더 작은 단위로 분할", option2: "트랜잭션의 타임아웃 시간을 늘림", option3: "모든 데이터를 메모리에 로드", option4: "트랜잭션의 격리 수준을 낮춤", timeLimit: 70, questionNumber: i + 1)
            }
            list.append(question)
        }
        return list
    }()
}
