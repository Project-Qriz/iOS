//
//  ResultScoreCircularChartView.swift
//  ExamKit
//

import SwiftUI
import DesignSystem
import QRIZUtils

public struct ResultScoreCircularChartView: View {

    // MARK: - Properties
    @ObservedObject public var resultScoresData: ResultScoresData
    private let lineWidth: CGFloat = 36
    private let rankColors: [Color] = [.customBlue900, .customBlue500, .customBlue300, .customBlue200, .customBlue100]

    // MARK: - Initializers
    public init(resultScoresData: ResultScoresData) {
        self.resultScoresData = resultScoresData
    }

    // MARK: - Body
    public var body: some View {
        ZStack {
            Circle()
                .stroke(style: StrokeStyle(lineWidth: lineWidth))
                .foregroundStyle(Color.customBlue800)
            ForEach(0..<5) {
                trimmedCircle(at: $0)
            }
            VStack {
                Text(resultScoresData.selectedMenuItem == .total ? "총점수" : "과목 점수")
                    .font(.system(size: 14, weight: .regular))
                Text("\(resultScoresData.totalScore)점")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundStyle(Color.coolNeutral800)
        }
        .padding(lineWidth / 2)
    }

    // MARK: - Methods
    @ViewBuilder
    private func trimmedCircle(at index: Int) -> some View {
        Circle()
            .trim(from: 0, to: 1.0 - resultScoresData.cumulativePercentage(idx: index))
            .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt, lineJoin: .round))
            .foregroundStyle(rankColor(at: index + 1))
            .rotationEffect(.degrees(-90))
            .animation(.easeInOut(duration: 1), value: resultScoresData.totalScore)
    }

    private func rankColor(at index: Int) -> Color {
        if index == resultScoresData.subjectCount { return .coolNeutral300 }
        guard rankColors.indices.contains(index) else { return .coolNeutral300 }
        return rankColors[index]
    }
}

#Preview {
    ResultScoreCircularChartView(resultScoresData: ResultScoresData())
}
