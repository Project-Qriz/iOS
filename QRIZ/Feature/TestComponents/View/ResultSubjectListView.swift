//
//  SubjectListView.swift
//  QRIZ
//
//  Created by 이창현 on 4/19/25.
//

import SwiftUI

struct ResultSubjectListView: View {
    
    @ObservedObject var resultDetailData: ResultDetailData
    private let rankColors: [Color] = [.customBlue900, .customBlue500, .customBlue300, .customBlue200, .customBlue100]
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach((resultDetailData.subject1DetailResult + resultDetailData.subject2DetailResult).indices, id: \.self) { idx in
                SingleSubjectView(circleColor: rankColors[idx],
                                  subjectText: (resultDetailData.subject1DetailResult + resultDetailData.subject2DetailResult)[idx].majorItem,
                                  score: (resultDetailData.subject1DetailResult + resultDetailData.subject2DetailResult)[idx].score)
                if idx != resultDetailData.numOfDataToPresent - 1 {
                    Divider()
                        .overlay(Color.coolNeutral200)
                }
            }
        }
    }
}

#Preview {
    ResultSubjectListView(resultDetailData: ResultDetailData())
}
