//
//  PreviewScoresData.swift
//  QRIZ
//
//  Created by ch on 12/29/24.
//

import SwiftUI

final class ResultScoresData: ObservableObject {
    @Published var subject1Score: CGFloat = 0
    @Published var subject2Score: CGFloat = 0
    @Published var subject3Score: CGFloat = 0
    @Published var subject4Score: CGFloat = 0
    @Published var subject5Score: CGFloat = 0

    var subjectScores: [CGFloat] {
        return [subject1Score, subject2Score, subject3Score, subject4Score, subject5Score]
    }
    var totalScore: Int {
        Int(subject1Score + subject2Score + subject3Score + subject4Score + subject5Score)
    }
    
    func cumulativePercentage(idx: Int) -> CGFloat {
        if idx < 0 || idx > 4 {
            return 0
        }

        var sum: CGFloat = 0
        for i in 0...idx {
            sum += subjectScores[idx]
        }
        return sum / 100
    }
    // nickname, expectScore
}
