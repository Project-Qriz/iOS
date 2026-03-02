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

    private var subjectResults: [SubjectDetailData] {
        resultDetailData.subject1DetailResult + resultDetailData.subject2DetailResult
    }

    public init(resultDetailData: ResultDetailData) {
        self.resultDetailData = resultDetailData
    }

    public var body: some View {
        VStack(spacing: 8) {
            ForEach(Array(subjectResults.enumerated()), id: \.offset) { idx, subject in
                SingleSubjectView(
                    circleColor: rankColors[idx],
                    subjectText: subject.majorItem,
                    score: subject.score
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
    let data = ResultDetailData()
    data.subject1DetailResult = [
        SubjectDetailData(majorItem: "데이터 모델링의 이해", score: 40, minorItems: [
            SubItemInfoEntity(subItem: "엔터티", score: 20),
            SubItemInfoEntity(subItem: "속성", score: 10),
            SubItemInfoEntity(subItem: "관계", score: 10)
        ]),
        SubjectDetailData(majorItem: "데이터 모델과 성능", score: 15, minorItems: [
            SubItemInfoEntity(subItem: "정규화", score: 10),
            SubItemInfoEntity(subItem: "반정규화", score: 5)
        ])
    ]
    data.subject2DetailResult = [
        SubjectDetailData(majorItem: "SQL 기본", score: 30, minorItems: [
            SubItemInfoEntity(subItem: "SELECT", score: 15),
            SubItemInfoEntity(subItem: "JOIN", score: 15)
        ]),
        SubjectDetailData(majorItem: "SQL 활용", score: 25, minorItems: [
            SubItemInfoEntity(subItem: "서브쿼리", score: 10),
            SubItemInfoEntity(subItem: "윈도우 함수", score: 15)
        ])
    ]
    data.numOfDataToPresent = 4
    return ResultSubjectListView(resultDetailData: data)
}
