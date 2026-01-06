//
//  ProblemQuestionData.swift
//  QRIZ
//
//  Created by Claude on 12/30/25.
//

import Foundation

/// 문제 섹션 데이터
struct ProblemQuestionData {
    let questionNumber: Int         // 2
    let questionText: String        // "다음 요구사항을 만족하는 가장 적절한 SQL문은?"
    let description: String?        // 추가 설명 (마크다운)
    let options: [OptionData]       // 4개 옵션
}

/// 옵션 데이터
struct OptionData {
    let number: Int                 // 1-4
    let text: String                // 옵션 텍스트
    let state: OptionState          // 상태 (정답/오답/일반)
}

/// 옵션 상태
enum OptionState {
    case normal                     // 일반 (회색)
    case correct                    // 정답 (파란색)
    case incorrect                  // 오답 (빨간색)
}

// MARK: - Helper Extensions

extension DailyResultDetail {

    /// 헤더 카드 데이터로 변환
    var headerData: ProblemHeaderData {
        ProblemHeaderData(
            isCorrect: correction,
            examTitle: testInfo,
            subject: title,
            questionNumber: questionNum,
            tags: keyConcepts.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        )
    }

    /// 문제 섹션 데이터로 변환
    var questionData: ProblemQuestionData {
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
