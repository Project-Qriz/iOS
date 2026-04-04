//
//  DailyResultScoreView.swift
//  QRIZ
//
//  Created by 이창현 on 4/16/25.
//

import SwiftUI
import DesignSystem
import QRIZUtils
import ExamKit

struct DailyResultScoreView: View {

    // MARK: - Properties

    @ObservedObject var resultScoresData: ResultScoresData
    @ObservedObject var resultDetailData: ResultDetailData
    let dailyLearnType: DailyLearnType
    let onDetailTap: () -> Void

    // MARK: - Body

    var body: some View {
        VStack(spacing: 24) {
            titleText
            dayNumRow
            ResultScoreCircularChartView(resultScoresData: resultScoresData)
                .frame(width: 164, height: 164)
            ResultSubjectListView(resultDetailData: resultDetailData)
            if dailyLearnType == .weekly {
                detailButton
            }
        }
        .padding(EdgeInsets(top: 24, leading: 18, bottom: 24, trailing: 18))
        .background(.white)
    }
}

// MARK: - Subviews

private extension DailyResultScoreView {

    var titleText: some View {
        HStack {
            (
                Text("\(resultScoresData.nickname) 님의\n").font(.system(size: 20, weight: .regular)) +
                Text("\(dailyLearnType.rawValue) 결과").font(.system(size: 20, weight: .bold)) +
                Text("에요!").font(.system(size: 20, weight: .regular))
            )
            .foregroundStyle(Color.coolNeutral800)
            Spacer()
        }
    }

    var dayNumRow: some View {
        HStack {
            Text(resultScoresData.dayNum)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color.coolNeutral600)
            if !resultScoresData.passed {
                Text("점수 미달")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.customRed500)
                    .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                    .background(Color.customRed500.opacity(0.14), in: RoundedRectangle(cornerRadius: 4))
            }
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
    DailyResultScoreView(
        resultScoresData: ResultScoresData(),
        resultDetailData: ResultDetailData(),
        dailyLearnType: .weekly,
        onDetailTap: {}
    )
}
