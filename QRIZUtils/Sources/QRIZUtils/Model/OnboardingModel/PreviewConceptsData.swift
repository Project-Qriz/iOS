//
//  PreviewConceptsData.swift
//  QRIZ
//
//  Created by ch on 12/29/24.
//

import SwiftUI

public final class PreviewConceptsData: ObservableObject {
    @Published public var totalQuestions: Int = 0
    @Published public var incorrectCountDataArr: [IncorrectCountData] = []
    @Published public var firstConcept: String = ""
    @Published public var secondConcept: String = ""
    @Published public var numOfChartToPresent: Int = 0

    public init(totalQuestions: Int, incorrectCountDataArr: [IncorrectCountData], firstConcept: String, secondConcept: String) {
        self.totalQuestions = totalQuestions
        self.incorrectCountDataArr = incorrectCountDataArr
        self.firstConcept = firstConcept
        self.secondConcept = secondConcept
    }

    public init() {}

    public func initAnimationChart() {
        if numOfChartToPresent > 1 {
            for idx in 1...numOfChartToPresent {
                incorrectCountDataArr.append(IncorrectCountData(id: idx, incorrectCount: 0, topic: [""]))
            }
        }
    }
}
