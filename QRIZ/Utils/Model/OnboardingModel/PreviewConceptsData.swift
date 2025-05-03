//
//  PreviewConceptsData.swift
//  QRIZ
//
//  Created by ch on 12/29/24.
//

import SwiftUI

final class PreviewConceptsData: ObservableObject {
    @Published var totalQuestions: Int = 0
    @Published var incorrectCountDataArr: [IncorrectCountData] = []
    @Published var firstConcept: String = ""
    @Published var secondConcept: String = ""
    @Published var numOfChartToPresent: Int = 0
    
    init(totalQuestions: Int, incorrectCountDataArr: [IncorrectCountData], firstConcept: String, secondConcept: String) {
        self.totalQuestions = totalQuestions
        self.incorrectCountDataArr = incorrectCountDataArr
        self.firstConcept = firstConcept
        self.secondConcept = secondConcept
    }
    
    init() {}
    
    func initAnimationChart() {
        if numOfChartToPresent > 1 {
            for idx in 1...numOfChartToPresent {
                incorrectCountDataArr.append(IncorrectCountData(id: idx, incorrectCount: 0, topic: [""]))
            }
        }
    }
}
