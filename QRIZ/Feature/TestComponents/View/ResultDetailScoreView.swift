//
//  ResultDetailScoreView.swift
//  QRIZ
//
//  Created by 이창현 on 4/20/25.
//

import SwiftUI

struct ResultDetailScoreView: View {
    
    @ObservedObject var resultScoreData: ResultScoresData
    @ObservedObject var resultDetailData: ResultDetailData
    @State var presentedSubject1ItemCount: Int = 0
    
    var body: some View {
        VStack(spacing: 32) {
            if resultScoreData.selectedMenuItem != .subject2 {
                ForEach(resultDetailData.subject1DetailResult.indices, id: \.self) { idx in
                    singleMajorSubjectView(subjectData: resultDetailData.subject1DetailResult[idx], rank: idx)
                }
            }
            if resultScoreData.selectedMenuItem != .subject1 {
                ForEach(resultDetailData.subject2DetailResult.indices, id: \.self) { idx in
                    singleMajorSubjectView(subjectData: resultDetailData.subject2DetailResult[idx], rank: presentedSubject1ItemCount + idx)
                }
            }
        }
        .onAppear() {
            if resultScoreData.selectedMenuItem == .total {
                presentedSubject1ItemCount = resultDetailData.subject1DetailResult.count
            } else {
                presentedSubject1ItemCount = 0
            }
        }
    }
    
    @ViewBuilder
    private func singleMajorSubjectView(subjectData: SubjectDetailData, rank: Int) -> some View {
        VStack(spacing: 11) {
            HStack {
                Circle()
                    .frame(width: 12, height: 12)
                    .foregroundColor(rankColor(rank))
                Text(subjectData.majorItem)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.black)
                Spacer()
                
            }
            
            ForEach(subjectData.minorItems.indices, id: \.self) { idx in
                VStack(spacing: 8) {
                    HStack {
                        Text("\(subjectData.minorItems[idx].concept)")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(.black)
                        
                        Spacer()
                        
                        Text("\(Int(subjectData.minorItems[idx].score))점")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.coolNeutral800)
                    }

                    if idx != subjectData.minorItems.count - 1 {
                        Divider()
                            .overlay(Color.customBlue200)
                    }
                }
            }
        }
    }
    
    private func rankColor(_ rank: Int) -> Color {
        switch rank {
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
            print("Method rankColor received wrong argv")
            return .white
        }
    }
}

#Preview {
    ResultDetailScoreView(resultScoreData: ResultScoresData(), resultDetailData: ResultDetailData())
}
