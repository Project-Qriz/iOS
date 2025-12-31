//
//  ProblemResultView.swift
//  QRIZ
//
//  Created by Claude on 12/31/25.
//

import SwiftUI

struct ProblemResultView: View {
    
    let correctAnswer: Int
    let userAnswer: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            correctAnswerText
            userAnswerText
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(border)
    }
}

// MARK: - Subviews

private extension ProblemResultView {
    
    var correctAnswerText: some View {
        Text("정답: \(correctAnswer)번")
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(Color(.coolNeutral800))
    }
    
    var userAnswerText: some View {
        Text("내가 고른 답: \(userAnswer)번")
            .font(.system(size: 14))
            .foregroundColor(Color(.coolNeutral500))
    }
    
    var border: some View {
        RoundedRectangle(cornerRadius: 12)
            .stroke(Color(.coolNeutral200), lineWidth: 1.5)
    }
}

// MARK: - Preview

#Preview {
    ProblemResultView(
        correctAnswer: 2,
        userAnswer: 3
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
