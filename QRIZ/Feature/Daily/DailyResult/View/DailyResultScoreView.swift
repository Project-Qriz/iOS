//
//  DailyResultScoreView.swift
//  QRIZ
//
//  Created by 이창현 on 4/16/25.
//

import SwiftUI

struct DailyResultScoreView: View {
    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Text("채영님의\n").font(.system(size: 20, weight: .regular)) +
                Text("데일리 테스트 결과").font(.system(size: 20, weight: .bold)) +
                Text("에요!").font(.system(size: 20, weight: .regular))
                
                Spacer()
                
            }
            .foregroundStyle(.coolNeutral800)
            
            HStack {
                Text("DAY 1")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.coolNeutral600)
                Text("점수 미달")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.customRed500)
                    .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                    .background(Color.customRed500.opacity(0.14), in: RoundedRectangle(cornerRadius: 4))
            }

            ResultScoreCircularChartView(resultScoresData: .init())
                .frame(width: 164, height: 164)

            VStack(spacing: 8) {
                SingleSubjectView(circleColor: .customBlue800, subjectText: "식별자", score: 30)
                
                Divider()
                    .overlay(Color.coolNeutral200)
                
                SingleSubjectView(circleColor: .customBlue500, subjectText: "엔터티", score: 20)
            }
        }
        .padding(EdgeInsets(top: 24, leading: 18, bottom: 24, trailing: 18))
        .background(.white)
    }
}

#Preview {
    DailyResultScoreView()
}
