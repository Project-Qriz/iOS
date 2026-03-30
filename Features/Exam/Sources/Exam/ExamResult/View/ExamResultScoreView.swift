//
//  ExamResultScoreView.swift
//  QRIZ
//

import SwiftUI
import DesignSystem
import QRIZUtils
import ExamKit

struct ExamResultScoreView: View {

    // MARK: - Properties

    @ObservedObject var resultScoresData: ResultScoresData
    @ObservedObject var resultDetailData: ResultDetailData
    let onDetailTap: () -> Void

    // MARK: - Body

    var body: some View {
        VStack(spacing: 24) {
            titleText
            ResultScoreCircularChartView(resultScoresData: resultScoresData)
                .frame(width: 164, height: 164)
            ResultSubjectListView(resultDetailData: resultDetailData)
            detailButton
        }
        .padding(EdgeInsets(top: 24, leading: 18, bottom: 24, trailing: 18))
        .background(.white)
    }
}

// MARK: - Subviews

private extension ExamResultScoreView {

    var titleText: some View {
        HStack {
            (
                Text("\(resultScoresData.nickname) 님의\n").font(.system(size: 20, weight: .regular)) +
                Text("모의고사 결과").font(.system(size: 20, weight: .bold)) +
                Text("에요!").font(.system(size: 20, weight: .regular))
            )
            .foregroundStyle(Color.coolNeutral800)
            Spacer()
        }
    }

    var detailButton: some View {
        Button(action: onDetailTap) {
            Text("상세보기")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.coolNeutral800)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
        }
        .background(.white)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.customBlue200, lineWidth: 1))
    }
}

// MARK: - Preview

#Preview {
    ExamResultScoreView(
        resultScoresData: ResultScoresData(),
        resultDetailData: ResultDetailData(),
        onDetailTap: {}
    )
}
