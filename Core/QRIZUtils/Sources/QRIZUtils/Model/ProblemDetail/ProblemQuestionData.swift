//
//  ProblemQuestionData.swift
//  QRIZUtils
//
//  Created by Claude on 12/30/25.
//

import Foundation

/// 문제 섹션 데이터
public struct ProblemQuestionData {
    public let questionNumber: Int
    public let questionText: String
    public let description: String?
    public let options: [OptionData]

    public init(questionNumber: Int, questionText: String, description: String?, options: [OptionData]) {
        self.questionNumber = questionNumber
        self.questionText = questionText
        self.description = description
        self.options = options
    }
}

/// 옵션 데이터
public struct OptionData {
    public let number: Int
    public let text: String
    public let state: OptionState

    public init(number: Int, text: String, state: OptionState) {
        self.number = number
        self.text = text
        self.state = state
    }
}

/// 옵션 상태
public enum OptionState {
    case normal
    case correct
    case incorrect
}

extension DailyResultDetailEntity {

    /// 헤더 카드 데이터로 변환
    public var headerData: ProblemHeaderData {
        ProblemHeaderData(
            isCorrect: correction,
            examTitle: testInfo,
            subject: title,
            questionNumber: questionNum,
            tags: keyConcepts.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        )
    }

    /// 문제 섹션 데이터로 변환
    public var questionData: ProblemQuestionData {
        let optionTexts = [option1, option2, option3, option4]
        let optionStates = optionTexts.enumerated().map { index, _ -> OptionState in
            let optionNumber = index + 1
            let isCorrect = (optionNumber == answer)
            let isUserChoice = (optionNumber == checked)

            if isCorrect {
                return .correct
            } else if isUserChoice {
                return .incorrect
            } else {
                return .normal
            }
        }

        let options = optionTexts.enumerated().map { index, text in
            OptionData(
                number: index + 1,
                text: text,
                state: optionStates[index]
            )
        }

        return ProblemQuestionData(
            questionNumber: questionNum,
            questionText: questionText,
            description: description,
            options: options
        )
    }
}
