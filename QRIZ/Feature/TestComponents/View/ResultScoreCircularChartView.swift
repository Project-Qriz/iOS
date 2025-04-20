//
//  SwiftUIView.swift
//  QRIZ
//
//  Created by ch on 12/29/24.
//

import SwiftUI

struct ResultScoreCircularChartView: View {
    
    @ObservedObject var resultScoresData: ResultScoresData
    private let lineWidth: CGFloat = 36
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(style: StrokeStyle(lineWidth: lineWidth))
                .foregroundStyle(.customBlue800)
            ForEach(0..<5) {
                trimmedCircle(subjectIdx: ($0))
            }
            VStack {
                Text(resultScoresData.selectedMenuItem == .total ? "총점수" : "과목 점수")
                    .font(.system(size: 14, weight: .regular))
                Text("\(resultScoresData.totalScore)점")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundStyle(.coolNeutral800)
        }
        .padding(lineWidth / 2)
    }
    
    @ViewBuilder
    private func trimmedCircle(subjectIdx: Int) -> some View {
        Circle()
            .trim(from: 0.0, to: 1.0 - resultScoresData.cumulativePercentage(idx: subjectIdx))
            .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt, lineJoin: .round))
            .foregroundStyle(rankColor(subjectIdx: subjectIdx + 1))
            .rotationEffect(.degrees(-90))
            .animation(.easeInOut(duration: 1), value: resultScoresData.totalScore)
    }
    
    private func rankColor(subjectIdx: Int) -> Color {
        if subjectIdx == resultScoresData.subjectCount { return .coolNeutral300 }

        switch subjectIdx {
        case 0:
            return .customBlue900
        case 1:
            return .customBlue500
        case 2:
            return .customBlue300
        case 3:
            return .customBlue200
        case 4:
            return .customBlue100
        default:
            return .coolNeutral300
        }
    }
}

#Preview {
    ResultScoreCircularChartView(resultScoresData: ResultScoresData())
}
