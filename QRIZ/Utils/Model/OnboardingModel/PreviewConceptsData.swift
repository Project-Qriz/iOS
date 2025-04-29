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
    @Published var numOfTotalConcept: Int = 0
    
    init(totalQuestions: Int, incorrectCountDataArr: [IncorrectCountData], firstConcept: String, secondConcept: String) {
        self.totalQuestions = totalQuestions
        self.incorrectCountDataArr = incorrectCountDataArr
        self.firstConcept = firstConcept
        self.secondConcept = secondConcept
        
        var total: Int = 0
        for i in 0..<incorrectCountDataArr.count {
            total += incorrectCountDataArr[i].topic.count
        }
        self.numOfTotalConcept = total
    }
    
    init() {}
    
    func initAnimationChart(numOfCharts: Int) {
        for idx in 0..<numOfCharts {
            incorrectCountDataArr.append(IncorrectCountData(id: idx, incorrectCount: 0, topic: [""]))
        }
    }
}
