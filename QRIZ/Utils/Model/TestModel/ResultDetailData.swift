//
//  ResultDetailData.swift
//  QRIZ
//
//  Created by 이창현 on 4/19/25.
//

import Foundation

// 데일리 테스트에서 데일리 테스트 및 종합 복습 테스트 => subject1DetailResult에 majorItem으로 개념 채우고,
// score에 해당 개념의 점수를, minorItems를 빈 Array로 관리함.
// 데일리 테스트의 주간 복습 테스트 및 모의고사의 경우에는 각각 과목1, 과목2를
// subject1DetailResult, subject2DetailResult에 넣고,
// minorItems로 세부 개념 및 점수 관리.
final class ResultDetailData: ObservableObject {
    @Published var subject1DetailResult: [SubjectDetailData] = []
    @Published var subject2DetailResult: [SubjectDetailData] = []
    @Published var numOfDataToPresent: Int = 0
}

struct SubjectDetailData {
    var majorItem: String
    var score: CGFloat
    var minorItems: [SubItemInfo]
}
