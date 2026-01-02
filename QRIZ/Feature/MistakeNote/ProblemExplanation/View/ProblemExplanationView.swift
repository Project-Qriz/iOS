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
                ProblemHeaderCardView(data: data.headerData)
                    .padding(.bottom, 16)

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
                
                ProblemKeyConceptsView(
                    keyConcepts: data.keyConcepts,
                    subject: data.title
                ) // 활용된 개념 섹션

                learnButton // 학습하러가기 버튼
            }
            .padding(.horizontal, 18)
            .padding(.top, 16)
            .padding(.bottom, 12)
        }
        .background(Color.customBlue50)
        .navigationTitle("오답노트")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Subviews

private extension ProblemExplanationView {

    /// 학습하러가기 버튼
    var learnButton: some View {
        Button(action: {
            // TODO: 학습하러가기 동작 구현
        }) {
            Text("학습하러 가기")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color(.customBlue500))
                .cornerRadius(8)
        }
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
