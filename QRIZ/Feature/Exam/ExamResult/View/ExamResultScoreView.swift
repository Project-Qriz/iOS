//
//  ExamResultScoreView.swift
//  QRIZ
//
//  Created by 이창현 on 5/26/25.
//

import SwiftUI
import Combine

struct ExamResultScoreView: View {
    
    @ObservedObject var resultScoresData: ResultScoresData
    @ObservedObject var resultDetailData: ResultDetailData
    
    let input: PassthroughSubject<ExamResultViewModel.Input, Never>
    
    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Text("\(resultScoresData.nickname) 님의\n").font(.system(size: 20, weight: .regular)) +
                Text("모의고사 결과").font(.system(size: 20, weight: .bold)) +
                Text("에요!").font(.system(size: 20, weight: .regular))
                
                Spacer()
                
            }
            .foregroundStyle(.coolNeutral800)

            ResultScoreCircularChartView(resultScoresData: resultScoresData)
                .frame(width: 164, height: 164)

            ResultSubjectListView(resultDetailData: resultDetailData)
            
            Button {
                input.send(.resultDetailButtonClicked)
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
        .padding(EdgeInsets(top: 24, leading: 18, bottom: 24, trailing: 18))
        .background(.white)
    }
}

#Preview {
    ExamResultScoreView(resultScoresData: ResultScoresData(), resultDetailData: ResultDetailData(), input: PassthroughSubject<ExamResultViewModel.Input, Never>())
}
