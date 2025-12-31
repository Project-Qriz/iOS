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
            VStack(spacing: 20) {
                ProblemHeaderCardView(data: data.headerData)        // 헤더 카드
                ProblemQuestionSectionView(data: data.questionData) // 문제 섹션
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
