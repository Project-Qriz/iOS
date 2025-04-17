//
//  ResultCircularChartView.swift
//  QRIZ
//
//  Created by 이창현 on 4/17/25.
//

import SwiftUI

struct ResultCircularChartView: View {
    
    @ObservedObject var resultScoresData: ResultScoresData
    private let lineWidth: CGFloat = 36
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(style: StrokeStyle(lineWidth: lineWidth))
                .foregroundStyle(.customBlue900)
//            createTrimmedCircle(subject1Score: previewScoresData.subject1Score)
//            createTrimmedCircle(subject1Score: previewScoresData.subject1Score, subject2Score: previewScoresData.subject2Score)
            trimmedCircle(subjectIdx: 0)
            trimmedCircle(subjectIdx: 1)
            trimmedCircle(subjectIdx: 2)
            VStack {
                Text("총점수")
                    .font(.system(size: 14, weight: .regular))
                Text("\(resultScoresData.totalScore)점")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundStyle(.coolNeutral800)
        }
        .padding(lineWidth / 2)
        .onAppear() {
            DispatchQueue.main.async {
                resultScoresData.subject1Score = 10
                resultScoresData.subject2Score = 20
                resultScoresData.subject3Score = 30
            }
        }
    }
    
    
    private func createTrimmedCircle(subject1Score: CGFloat, subject2Score: CGFloat = -1.0) -> some View {
        subject2Score == -1.0 ?
        Circle()
            .trim(from: 0.0, to: 1.0 - subject1Score / 100)
            .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt, lineJoin: .round))
            .foregroundStyle(.customBlue500)
            .rotationEffect(.degrees(-90))
            .animation(.easeInOut(duration: 1), value: subject1Score)
        : Circle()
            .trim(from: 0.0, to: 1.0 - subject1Score / 100 - subject2Score / 100)
            .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt, lineJoin: .round))
            .foregroundStyle(.coolNeutral400)
            .rotationEffect(.degrees(-90))
            .animation(.easeInOut(duration: 1), value: subject2Score)
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
            print("Method trimmed Circle received wrong argv")
            return .coolNeutral300
        }
    }
}

#Preview {
    ResultCircularChartView(resultScoresData: ResultScoresData())
}
