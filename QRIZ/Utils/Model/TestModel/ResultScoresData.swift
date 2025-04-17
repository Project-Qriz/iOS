//
//  ResultScoresData.swift
//  QRIZ
//
//  Created by ch on 12/29/24.
//

import SwiftUI

final class ResultScoresData: ObservableObject {
    @Published var nickname: String = ""
    @Published var subject1Score: CGFloat = 0
    @Published var subject2Score: CGFloat = 0
    @Published var subject3Score: CGFloat = 0
    @Published var subject4Score: CGFloat = 0
    @Published var subject5Score: CGFloat = 0
    @Published var expectScore: Int = 0
    
    var subjectScores: [CGFloat] {
        [subject1Score, subject2Score, subject3Score, subject4Score, subject5Score]
    }
    
    var totalScore: Int {
        var sum: Int = 0
        subjectScores.forEach { sum += Int($0) }
        return sum
    }
}
