//
//  PreviewResultScoreView.swift
//  QRIZ
//
//  Created by ch on 3/11/25.
//

import SwiftUI

fileprivate struct SingleSubjectView: View {
    
    private let circleColor: Color
    private let subjectText: String
    private let score: Int
    
    init(circleColor: Color, subjectText: String, score: CGFloat) {
        self.circleColor = circleColor
        self.subjectText = subjectText
        self.score = Int(score)
    }

    var body: some View {
        HStack {
            Circle()
                .frame(width: 8, height: 8)
                .foregroundColor(circleColor)
            Text(subjectText)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(.black)
            Spacer()
            Text("\(score)점")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.coolNeutral800)
        }
    }
}

struct PreviewResultScoreView: View {
    
    @ObservedObject var previewScoresData: PreviewScoresData
    
    var body: some View {
        VStack {
            HStack {
                Text("\(previewScoresData.nickname) 님의\n").font(.system(size: 20, weight: .medium)) +
                Text("프리뷰 결과에요!").font(.system(size: 20, weight: .bold))
                
                Spacer()
            }
            .foregroundStyle(.coolNeutral800)
            
            Spacer(minLength: 24)
            
            PreviewResultScoreCircularChartView(previewScoresData: previewScoresData)
                .frame(width: 164, height: 164)
            
            Spacer(minLength: 15)
            
            Text("예측 점수: \(previewScoresData.expectScore)점")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.coolNeutral700)
            
            Spacer(minLength: 35)
            
            SingleSubjectView(circleColor: .customBlue800, subjectText: "데이터 모델링의 이해", score: previewScoresData.subject1Score)

            Divider()
                .overlay(Color.coolNeutral200)

            SingleSubjectView(circleColor: .customBlue500, subjectText: "SQL 기본 및 활용", score: previewScoresData.subject2Score)
        }
        .padding(EdgeInsets(top: 24, leading: 18, bottom: 24, trailing: 18))
    }
}

#Preview {
    PreviewResultScoreView(previewScoresData: PreviewScoresData())
}
