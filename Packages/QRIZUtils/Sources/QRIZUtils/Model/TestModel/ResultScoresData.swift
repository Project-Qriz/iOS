//
//  ResultScoresData.swift
//  QRIZ
//
//  Created by ch on 12/29/24.
//

import SwiftUI

public final class ResultScoresData: ObservableObject {
    @Published public var nickname: String = ""
    @Published public var subjectScores: [CGFloat] = [0, 0, 0, 0, 0]
    @Published public var expectScore: CGFloat = 0
    @Published public var subjectCount: Int = 0
    @Published public var passed: Bool = false
    @Published public var dayNum: String = ""
    @Published public var selectedMenuItem: ResultDetailMenuItems = .total

    public init() {}

    public var totalScore: Int {
        if subjectScores.count == 0 { return 0 }
        return subjectScores.reduce(0) { $0 + Int($1) }
    }

    public func cumulativePercentage(idx: Int) -> CGFloat {
        var sum: CGFloat = 0.0
        (0...idx).forEach({
            guard idx >= 0 && idx < 5 else { return }
            sum += subjectScores[$0] })
        return sum / 100
    }
}
