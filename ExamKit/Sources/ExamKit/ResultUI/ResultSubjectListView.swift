//
//  ResultSubjectListView.swift
//  ExamKit
//

import SwiftUI
import DesignSystem
import QRIZUtils

public struct ResultSubjectListView: View {

    @ObservedObject public var resultDetailData: ResultDetailData
    private let rankColors: [Color] = [.customBlue900, .customBlue500, .customBlue300, .customBlue200, .customBlue100]

    public init(resultDetailData: ResultDetailData) {
        self.resultDetailData = resultDetailData
    }

    public var body: some View {
        VStack(spacing: 8) {
            ForEach((resultDetailData.subject1DetailResult + resultDetailData.subject2DetailResult).indices, id: \.self) { idx in
                SingleSubjectView(
                    circleColor: rankColors[idx],
                    subjectText: (resultDetailData.subject1DetailResult + resultDetailData.subject2DetailResult)[idx].majorItem,
                    score: (resultDetailData.subject1DetailResult + resultDetailData.subject2DetailResult)[idx].score
                )
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
