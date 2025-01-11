//
//  IncorrectConceptsRankView.swift
//  QRIZ
//
//  Created by ch on 1/5/25.
//

import SwiftUI

struct IncorrectConceptsRankView: View {
    
    @ObservedObject var previewConceptsData: PreviewConceptsData
    
    var body: some View {
        VStack(spacing: 8) {

            ForEach(0..<2) { idx in
                if previewConceptsData.incorrectCountDataArr.count > idx {
                    IncorrectRankView(rank: previewConceptsData.incorrectCountDataArr[idx].id, topic: previewConceptsData.incorrectCountDataArr[idx].topic, incorrectNum: previewConceptsData.incorrectCountDataArr[idx].incorrectCount)
                }
            }
            
            if previewConceptsData.incorrectCountDataArr.count > 2 {
                HStack(spacing: 8) {
                    Text("\(previewConceptsData.incorrectCountDataArr[2].topic)")
                        .font(.system(size: 14))
                        .foregroundColor(.coolNeutral500)
                    
                    Spacer()
                    
                    Text("\(previewConceptsData.incorrectCountDataArr[2].incorrectCount)문제")
                        .font(.system(size: 16))
                        .foregroundColor(.coolNeutral500)
                }
            }
        }
    }
}

#Preview {
    IncorrectConceptsRankView(previewConceptsData: PreviewConceptsData(totalQuestions: 3, incorrectCountDataArr: [
        IncorrectCountData(id: 1, topic: "DDL", incorrectCount: 5),
        IncorrectCountData(id: 2, topic: "조인", incorrectCount: 3),
        IncorrectCountData(id: 3, topic: "모델이 표현하는 트랜잭션의 이해", incorrectCount: 1)
    ]))
}
