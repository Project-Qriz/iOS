import Foundation
@testable import MistakeNote
import QRIZUtils

let asyncSleepNanoseconds: UInt64 = 100_000_000

// MARK: - Test Fixtures

extension MistakeNoteQuestion {
    static func make(
        id: Int = 1,
        questionNum: Int = 1,
        question: String = "테스트 문제",
        correction: Bool = false,
        keyConcepts: String = "SELECT문",
        date: String = "2026-01-01"
    ) -> MistakeNoteQuestion {
        MistakeNoteQuestion(
            id: id,
            questionNum: questionNum,
            question: question,
            correction: correction,
            keyConcepts: keyConcepts,
            date: date
        )
    }
}

extension DailyResultDetailEntity {
    static func make(
        skillName: String = "SQL 기본",
        questionText: String = "테스트 문제",
        questionNum: Int = 1,
        description: String? = nil,
        option1: String = "1번",
        option2: String = "2번",
        option3: String = "3번",
        option4: String = "4번",
        answer: Int = 1,
        solution: String = "해설",
        checked: Int? = 2,
        correction: Bool = false,
        testInfo: String = "Day1",
        skillId: Int = 1,
        title: String = "1과목",
        keyConcepts: String = "SELECT문"
    ) -> DailyResultDetailEntity {
        DailyResultDetailEntity(
            skillName: skillName,
            questionText: questionText,
            questionNum: questionNum,
            description: description,
            option1: option1,
            option2: option2,
            option3: option3,
            option4: option4,
            answer: answer,
            solution: solution,
            checked: checked,
            correction: correction,
            testInfo: testInfo,
            skillId: skillId,
            title: title,
            keyConcepts: keyConcepts
        )
    }
}
