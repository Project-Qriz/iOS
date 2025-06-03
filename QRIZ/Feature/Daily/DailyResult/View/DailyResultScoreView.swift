//
//  DailyResultScoreView.swift
//  QRIZ
//
//  Created by 이창현 on 4/16/25.
//

import SwiftUI
import Combine

struct DailyResultScoreView: View {
    
    @ObservedObject var resultScoresData: ResultScoresData
    @ObservedObject var resultDetailData: ResultDetailData
    @Binding var dailyLearnType: DailyLearnType
    
    let input: PassthroughSubject<Void, Never>
    
    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Text("\(resultScoresData.nickname) 님의\n").font(.system(size: 20, weight: .regular)) +
                Text("\(dailyLearnType.rawValue) 결과").font(.system(size: 20, weight: .bold)) +
                Text("에요!").font(.system(size: 20, weight: .regular))
                
                Spacer()
                
            }
            .foregroundStyle(.coolNeutral800)
            
            HStack {
                Text("\(resultScoresData.dayNum)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.coolNeutral600)
                if !resultScoresData.passed {
                    Text("점수 미달")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.customRed500)
                        .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                        .background(Color.customRed500.opacity(0.14), in: RoundedRectangle(cornerRadius: 4))
                }
            }

            ResultScoreCircularChartView(resultScoresData: resultScoresData)
                .frame(width: 164, height: 164)

            ResultSubjectListView(resultDetailData: resultDetailData)
            
            if dailyLearnType == .weekly {
                Button {
                    input.send()
                } label: {
                    Text("상세보기")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.coolNeutral800)
                        .background(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(.customBlue200, lineWidth: 1))
                }
            }
        }
        .padding(EdgeInsets(top: 24, leading: 18, bottom: 24, trailing: 18))
        .background(.white)
    }
}

#Preview {
    DailyResultScoreView(resultScoresData: ResultScoresData(), resultDetailData: ResultDetailData(), dailyLearnType: .constant(.weekly), input: PassthroughSubject<Void, Never>())
}
