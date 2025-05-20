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
    @Published var expectScore: CGFloat = 0
    @Published var subjectCount: Int = 0
    @Published var passed: Bool = false
    @Published var dayNum: String = ""
    @Published var selectedMenuItem: ResultDetailMenuItems = .total
    
    var totalScore: Int {
        if subjectScores.count == 0 { return 0 }
        return subjectScores.reduce(0) { $0 + Int($1) }
    }
    
    func cumulativePercentage(idx: Int) -> CGFloat {
        var sum: CGFloat = 0.0
        (0...idx).forEach({
            guard idx >= 0 && idx < 5 else { return }
            sum += subjectScores[$0] })
        return sum / 100
    }
}
