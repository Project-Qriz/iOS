//
//  ResultScoresData.swift
//  QRIZUtils
//
//  Created by ch on 12/29/24.
//

import Combine

public final class ResultScoresData: ObservableObject {
    @Published public var nickname: String = ""
    @Published public var subjectScores: [Double] = [0, 0, 0, 0, 0]
    @Published public var expectScore: Double = 0
    @Published public var subjectCount: Int = 0
    @Published public var passed: Bool = false
    @Published public var dayNum: String = ""
    @Published public var selectedMenuItem: ResultDetailMenuItems = .total

    public init() {}

    public var totalScore: Int {
        if subjectScores.count == 0 { return 0 }
        return subjectScores.reduce(0) { $0 + Int($1) }
    }

    public func cumulativePercentage(idx: Int) -> Double {
        guard idx >= 0 && idx < subjectScores.count else { return 0 }
        var sum: Double = 0.0
        (0...idx).forEach { sum += subjectScores[$0] }
        return sum / 100
    }
}
