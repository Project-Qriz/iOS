//
//  ResultScoresData.swift
//  QRIZ
//
//  Created by ch on 12/29/24.
//

import SwiftUI

final class ResultScoresData: ObservableObject {
    @Published var nickname: String = ""
    @Published var subjectScores: [CGFloat] = [0, 0, 0, 0, 0]
    @Published var expectScore: Int = 0
    @Published var subjectCount: Int = 0
    @Published var passed: Bool = false
    @Published var dayNum: String = ""
    
    var totalScore: Int {
        var sum: Int = 0
        subjectScores.forEach { sum += Int($0) }
        return sum
    }
    
    func cumulativePercentage(idx: Int) -> CGFloat {
        var sum: CGFloat = 0.0
        (0...idx).forEach({ sum += subjectScores[$0] })
        return sum / 100
    }
}
