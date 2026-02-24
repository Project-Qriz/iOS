//
//  ResultCircularChartView.swift
//  ExamKit
//

import SwiftUI
import DesignSystem
import QRIZUtils

public struct ResultCircularChartView: View {

    @ObservedObject public var resultScoresData: ResultScoresData
    private let lineWidth: CGFloat = 36

    public init(resultScoresData: ResultScoresData) {
        self.resultScoresData = resultScoresData
    }

    public var body: some View {
        ZStack {
            Circle()
                .stroke(style: StrokeStyle(lineWidth: lineWidth))
                .foregroundStyle(Color.customBlue900)
            trimmedCircle(subjectIdx: 0)
            trimmedCircle(subjectIdx: 1)
            trimmedCircle(subjectIdx: 2)
            VStack {
                Text("총점수")
                    .font(.system(size: 14, weight: .regular))
                Text("\(resultScoresData.totalScore)점")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundStyle(Color.coolNeutral800)
        }
        .padding(lineWidth / 2)
    }

    @ViewBuilder
    private func trimmedCircle(subjectIdx: Int) -> some View {
        Circle()
            .trim(from: 0, to: 1.0 - resultScoresData.cumulativePercentage(idx: subjectIdx))
            .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt, lineJoin: .round))
            .foregroundStyle(rankColor(subjectIdx: subjectIdx + 1))
            .rotationEffect(.degrees(-90))
            .animation(.easeInOut(duration: 1), value: resultScoresData.totalScore)
    }

    private func rankColor(subjectIdx: Int) -> Color {
        switch subjectIdx {
        case 0: return Color.customBlue900
        case 1: return Color.customBlue500
        case 2: return Color.customBlue300
        case 3: return Color.customBlue200
        case 4: return Color.customBlue100
        default:
            print("Method trimmedCircle received wrong argv")
            return Color.coolNeutral300
        }
    }
}

#Preview {
    ResultCircularChartView(resultScoresData: ResultScoresData())
}
