//
//  IncorrectConceptsRankView.swift
//  QRIZ
//
//  Created by ch on 1/5/25.
//

import SwiftUI

struct IncorrectConceptsRankView: View {
    
    @EnvironmentObject var previewConceptsData: PreviewConceptsData
    
    var body: some View {
        VStack(spacing: 8) {
            if previewConceptsData.incorrectCountDataArr.count > 0 {
                IncorrectRankView(rank: previewConceptsData.incorrectCountDataArr[0].id, topic: previewConceptsData.incorrectCountDataArr[0].topic, incorrectNum: previewConceptsData.incorrectCountDataArr[0].incorrectCount)
            }
            
            if previewConceptsData.incorrectCountDataArr.count > 1 {
                IncorrectRankView(rank: previewConceptsData.incorrectCountDataArr[1].id, topic: previewConceptsData.incorrectCountDataArr[1].topic, incorrectNum: previewConceptsData.incorrectCountDataArr[1].incorrectCount)
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
    IncorrectConceptsRankView()
        .environmentObject(PreviewConceptsData(totalQuestions: 3, incorrectCountDataArr: [
            IncorrectCountData(id: 1, topic: "DDL", incorrectCount: 5),
            IncorrectCountData(id: 2, topic: "조인", incorrectCount: 3),
            IncorrectCountData(id: 3, topic: "모델이 표현하는 트랜잭션의 이해", incorrectCount: 1)
        ]))
}
