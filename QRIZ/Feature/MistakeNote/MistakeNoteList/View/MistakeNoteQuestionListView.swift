//
//  MistakeNoteQuestionListView.swift
//  QRIZ
//
//  Created by Claude on 1/20/26.
//

import SwiftUI

struct MistakeNoteQuestionListView: View {

    // MARK: - Properties

    let questions: [MistakeNoteQuestion]

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            countLabel
            questionCards
        }
    }
}

// MARK: - Subviews

private extension MistakeNoteQuestionListView {

    var countLabel: some View {
        Text("\(questions.count)개")
            .font(.system(size: 14, weight: .regular))
            .foregroundColor(Color(uiColor: .coolNeutral500))
    }

    var questionCards: some View {
        VStack(spacing: 12) {
            ForEach(questions) { question in
                MistakeNoteQuestionCard(
                    questionNumber: question.questionNum,
                    questionText: question.question,
                    keyConcepts: question.keyConcepts,
                    isCorrect: question.correction
                )
            }
        }
    }
}

// MARK: - Data Model

struct MistakeNoteQuestion: Identifiable, Decodable {
    let id: Int
    let questionNum: Int
    let question: String
    let correction: Bool
    let keyConcepts: String
    let date: String
}

// MARK: - Preview

#Preview {
    ScrollView {
        MistakeNoteQuestionListView(
            questions: [
                MistakeNoteQuestion(
                    id: 232371,
                    questionNum: 1,
                    question: "다음 SQL문에서 발생할 수 있는 문제점으로 가장 적절한 것은?",
                    correction: false,
                    keyConcepts: "WHERE 절",
                    date: "2026-01-10T20:21:16.217871"
                ),
                MistakeNoteQuestion(
                    id: 232372,
                    questionNum: 2,
                    question: "다음 중 가장 적절한 속성 설계는?",
                    correction: true,
                    keyConcepts: "속성",
                    date: "2026-01-10T20:21:16.231237"
                ),
                MistakeNoteQuestion(
                    id: 232373,
                    questionNum: 3,
                    question: "다음과 같은 WHERE 절에서 인덱스를 효율적으로 사용할 수 있는 조건은?",
                    correction: false,
                    keyConcepts: "WHERE 절",
                    date: "2026-01-10T20:21:16.234266"
                )
            ]
        )
        .padding(.horizontal, 18)
    }
    .background(Color(uiColor: .systemGroupedBackground))
}
