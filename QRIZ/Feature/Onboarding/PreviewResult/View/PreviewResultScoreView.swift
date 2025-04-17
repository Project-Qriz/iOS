//
//  PreviewResultScoreView.swift
//  QRIZ
//
//  Created by ch on 3/11/25.
//

import SwiftUI

struct PreviewResultScoreView: View {
    
    @ObservedObject var previewScoresData: ResultScoresData
    @State private var isShowingPopover = false
    
    var body: some View {
        VStack {
            HStack {
                Text("\(previewScoresData.nickname) 님의\n").font(.system(size: 20, weight: .regular)) +
                Text("프리뷰 결과").font(.system(size: 20, weight: .bold)) +
                Text("에요!").font(.system(size: 20, weight: .regular))
                
                Spacer()
            }
            .foregroundStyle(.coolNeutral800)
            
            Spacer(minLength: 24)
            
            ZStack(alignment: .bottom) {
                ResultScoreCircularChartView(resultScoresData: previewScoresData)
                    .frame(width: 164, height: 164)
                if isShowingPopover {
                    PreviewResultInfoView(isShowingPopover: $isShowingPopover)
                }
            }
            
            Spacer(minLength: 15)
            
            HStack(spacing: 4) {
                Text("예측 점수: \(previewScoresData.expectScore)점")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.coolNeutral700)
                Button(action: {
                    isShowingPopover.toggle()
                }) {
                    Image(systemName: "info.circle")
                        .resizable()
                        .frame(width: 13, height: 13)
                        .foregroundStyle(.coolNeutral300)
                }
            }
            
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
    PreviewResultScoreView(previewScoresData: ResultScoresData())
}
