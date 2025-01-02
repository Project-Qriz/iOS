//
//  PreviewConceptsData.swift
//  QRIZ
//
//  Created by ch on 12/29/24.
//

import SwiftUI

final class PreviewConceptsData: ObservableObject {
    @Published var totalQuestions: Int = 0
    @Published var incorrectCountDataArr: [IncorrectCountData] = [
        IncorrectCountData(id: 1, topic: "", incorrectCount: 0),
        IncorrectCountData(id: 2, topic: "", incorrectCount: 0),
        IncorrectCountData(id: 3, topic: "", incorrectCount: 0),
    ]
    
    init() {}

    init(totalQuestions: Int, incorrectCountDataArr: [IncorrectCountData]) {
        self.totalQuestions = totalQuestions
        self.incorrectCountDataArr = incorrectCountDataArr
    }    
}
