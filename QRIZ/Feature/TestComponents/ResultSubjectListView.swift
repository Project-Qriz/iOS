//
//  SubjectListView.swift
//  QRIZ
//
//  Created by 이창현 on 4/19/25.
//

import SwiftUI

struct ResultSubjectListView: View {
    
    @ObservedObject var resultDetailData: ResultDetailData
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach((resultDetailData.subject1DetailResult + resultDetailData.subject2DetailResult).indices, id: \.self) { idx in
                SingleSubjectView(circleColor: rankColor(idx),
                                  subjectText: (resultDetailData.subject1DetailResult + resultDetailData.subject2DetailResult)[idx].majorItem,
                                  score: (resultDetailData.subject1DetailResult + resultDetailData.subject2DetailResult)[idx].score)
                if idx != resultDetailData.numOfDataToPresent - 1 {
                    Divider()
                        .overlay(Color.coolNeutral200)
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
    ResultSubjectListView(resultDetailData: ResultDetailData())
}
