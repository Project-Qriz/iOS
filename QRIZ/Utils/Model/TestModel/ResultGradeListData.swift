//
//  ResultGradeListData.swift
//  QRIZ
//
//  Created by 이창현 on 4/18/25.
//

import Foundation

final class ResultGradeListData: ObservableObject {
    @Published var gradeResultList: [GradeResult] = []
}

struct GradeResult: Identifiable {
    var id: Int
    var skillName: String
    var question: String
    var correction: Bool
}
