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
    
    init(totalQuestions: Int, incorrectCountDataArr: [IncorrectCountData], firstConcept: String, secondConcept: String) {
        self.totalQuestions = totalQuestions
        self.incorrectCountDataArr = incorrectCountDataArr
        self.firstConcept = firstConcept
        self.secondConcept = secondConcept
    }
    
    init() {}
}
