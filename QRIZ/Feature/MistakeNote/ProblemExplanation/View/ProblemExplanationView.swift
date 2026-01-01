//
//  ProblemExplanationView.swift
//  QRIZ
//
//  Created by Claude on 12/30/25.
//

import SwiftUI

struct ProblemExplanationView: View {

    let data: DailyResultDetail

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                ProblemHeaderCardView(data: data.headerData) // 헤더 카드

                VStack(spacing: 8) {
                    ProblemQuestionSectionView(data: data.questionData) // 문제 섹션
                    ProblemResultView(
                        correctAnswer: data.answer,
                        userAnswer: data.checked ?? 0
                    ) // 정답 정보
                }

                ProblemSolutionView(
                    keyConcepts: data.keyConcepts,
                    solutionText: data.solution
                ) // 풀이 섹션
            }
            .padding(.horizontal, 18)
            .padding(.top, 16)
        }
        .background(Color.customBlue50)
        .navigationTitle("오답노트")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        ProblemExplanationView(
            data: MockDailyResultData.incorrectSample
        )
    }
}
