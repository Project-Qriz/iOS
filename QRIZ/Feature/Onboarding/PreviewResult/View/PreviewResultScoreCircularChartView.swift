//
//  SwiftUIView.swift
//  QRIZ
//
//  Created by ch on 12/29/24.
//

import SwiftUI

struct PreviewResultScoreCircularChartView: View {
    
    @ObservedObject var previewScoresData: PreviewScoresData
    private let lineWidth: CGFloat = 36
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(style: StrokeStyle(lineWidth: lineWidth))
                .foregroundStyle(.customBlue800)
            createTrimmedCircle(subject1Score: previewScoresData.subject1Score)
            createTrimmedCircle(subject1Score: previewScoresData.subject1Score, subject2Score: previewScoresData.subject2Score)
            VStack {
                Text("총점수")
                    .font(.system(size: 14, weight: .regular))
                Text("\(Int(previewScoresData.subject1Score + previewScoresData.subject2Score))점")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundStyle(.coolNeutral800)
        }
        .padding(lineWidth / 2)
    }
    
    private func createTrimmedCircle(subject1Score: CGFloat, subject2Score: CGFloat = -1.0) -> some View {
        subject2Score == -1.0 ?
        Circle()
            .trim(from: 0.0, to: 1.0 - subject1Score / 100)
            .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt, lineJoin: .round))
            .foregroundStyle(.customBlue500)
            .rotationEffect(.degrees(-90))
            .animation(.easeInOut(duration: 1), value: 1.0 - subject1Score)
        : Circle()
            .trim(from: 0.0, to: 1.0 - subject1Score / 100 - subject2Score / 100)
            .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt, lineJoin: .round))
            .foregroundStyle(.coolNeutral400)
            .rotationEffect(.degrees(-90))
            .animation(.easeInOut(duration: 1), value: subject1Score)
    }
}

#Preview {
    PreviewResultScoreCircularChartView(previewScoresData: PreviewScoresData())
}
