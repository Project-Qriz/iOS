//
//  ConceptBarGraphView.swift
//  QRIZ
//
//  Created by ch on 12/29/24.
//

import SwiftUI

struct ConceptBarGraphView: View {
    
    @StateObject var previewConceptsData: PreviewConceptsData
    
    var body: some View {
        VStack(spacing: 8) {
            
            Text("총 문제 개수")
                .font(.system(size: 18))
                .foregroundColor(.coolNeutral500)
            
            Text("20개")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.customBlue500)
            
            if previewConceptsData.incorrectCountDataArr.count > 1 {
                BarGraphsView(previewConceptsData: previewConceptsData)
            } else {
                Text("하나의 개념만 틀린 경우\n틀린 개념과 문제 개수만 보입니다.")
                    .font(.system(size: 14))
                    .foregroundColor(.coolNeutral500)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            IncorrectConceptsRankView(previewConceptsData: previewConceptsData)
            
            if previewConceptsData.incorrectCountDataArr.count > 3 {
                VStack(spacing: 4) {
                    ForEach(1..<4) { _ in
                        Circle()
                            .foregroundColor(.coolNeutral100)
                            .frame(width: 4, height: 4)
                    }
                }
            }
        }
        .background(.white)
        .padding(EdgeInsets(top: 24, leading: 50, bottom: 24, trailing: 50))
    }
}

#Preview {
    ConceptBarGraphView(previewConceptsData: PreviewConceptsData())
}
