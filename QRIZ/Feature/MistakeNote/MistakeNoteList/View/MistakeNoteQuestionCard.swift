//
//  MistakeNoteQuestionCard.swift
//  QRIZ
//
//  Created by Claude on 1/20/26.
//

import SwiftUI

struct MistakeNoteQuestionCard: View {

    // MARK: - Properties

    let questionNumber: Int
    let questionText: String
    let keyConcepts: String
    let isCorrect: Bool

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerRow
            questionDescription
            tagRow
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(
            color: Color(uiColor: .coolNeutral300).opacity(0.12),
            radius: 4,
            x: 0,
            y: 1
        )
    }
}

// MARK: - Subviews

private extension MistakeNoteQuestionCard {

    var headerRow: some View {
        HStack(spacing: 8) {
            resultIcon

            Text("문제 \(questionNumber)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(uiColor: .coolNeutral800))
        }
    }

    var resultIcon: some View {
        Text(isCorrect ? "✓" : "✕")
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(isCorrect ? Color(uiColor: .customMint600) : Color(uiColor: .customRed500))
    }

    var questionDescription: some View {
        Text(questionText)
            .font(.system(size: 14, weight: .regular))
            .foregroundColor(Color(uiColor: .coolNeutral500))
            .lineLimit(2)
            .lineSpacing(4)
    }

    var tagRow: some View {
        HStack(spacing: 8) {
            QuestionTagChip(text: keyConcepts)
        }
    }
}

// MARK: - Tag Chip

private struct QuestionTagChip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(Color(uiColor: .customBlue400))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(uiColor: .customBlue100))
            .cornerRadius(6)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 12) {
        MistakeNoteQuestionCard(
            questionNumber: 1,
            questionText: "다음 SQL문에서 발생할 수 있는 문제점으로 가장 적절한 것은?",
            keyConcepts: "WHERE 절",
            isCorrect: false
        )

        MistakeNoteQuestionCard(
            questionNumber: 2,
            questionText: "다음 중 가장 적절한 속성 설계는?",
            keyConcepts: "속성",
            isCorrect: true
        )

        MistakeNoteQuestionCard(
            questionNumber: 3,
            questionText: "다음과 같은 WHERE 절에서 인덱스를 효율적으로 사용할 수 있는 조건은?",
            keyConcepts: "WHERE 절",
            isCorrect: false
        )
    }
    .padding(.horizontal, 18)
    .background(Color(uiColor: .systemGroupedBackground))
}
