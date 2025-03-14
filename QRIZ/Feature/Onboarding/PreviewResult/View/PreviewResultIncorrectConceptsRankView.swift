//
//  IncorrectConceptsRankView.swift
//  QRIZ
//
//  Created by ch on 1/5/25.
//

import SwiftUI

struct PreviewResultIncorrectConceptsRankView: View {
    
    @ObservedObject var previewConceptsData: PreviewConceptsData
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(0..<3) { idx in
                if previewConceptsData.incorrectCountDataArr.count > idx {
                    PreviewResultIncorrectRankView(rank: $previewConceptsData.incorrectCountDataArr[idx].id, topic: $previewConceptsData.incorrectCountDataArr[idx].topic, incorrectNum: $previewConceptsData.incorrectCountDataArr[idx].incorrectCount)
                }
            }
        }
    }
}

#Preview {
    PreviewResultIncorrectConceptsRankView(previewConceptsData: PreviewConceptsData(
        totalQuestions: 20,
        incorrectCountDataArr: [
                    IncorrectCountData(id: 1, incorrectCount: 5, topic: ["DDL"]),
                    IncorrectCountData(id: 2, incorrectCount: 3, topic: ["조인"]),
                    IncorrectCountData(id: 3, incorrectCount: 1, topic: ["모델이 표현하는 트랜잭션의 이해"]),
        ],
        firstConcept: "",
        secondConcept: ""
    ))
}
