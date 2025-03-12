//
//  ConceptBarGraphView.swift
//  QRIZ
//
//  Created by ch on 12/29/24.
//

import SwiftUI

struct PreviewResultConceptBarGraphView: View {
    
    @StateObject var previewConceptsData: PreviewConceptsData
    
    private var hasMultipleIncorrectConcepts: Bool {
        previewConceptsData.incorrectCountDataArr.count > 1
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("총 문제 개수: 20개")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.coolNeutral500)
                Spacer()
            }
            
            Spacer(minLength: 12)
            
            if hasMultipleIncorrectConcepts {
                PreviewResultBarGraphsView(previewConceptsData: previewConceptsData)
            } else {
                Text("하나의 개념만 틀린 경우\n틀린 개념과 문제 개수만 보입니다.")
                    .font(.system(size: 14))
                    .foregroundStyle(.coolNeutral500)
                    .multilineTextAlignment(.center)
            }
            
            Spacer(minLength: 8)
            
            PreviewResultIncorrectConceptsRankView(previewConceptsData: previewConceptsData)
            
            if previewConceptsData.incorrectCountDataArr.count > 3 {
                VStack(spacing: 4) {
                    ForEach(1..<4) { _ in
                        Circle()
                            .foregroundStyle(.coolNeutral100)
                            .frame(width: 4, height: 4)
                    }
                }
            }
        }
        .background(.white)
        .padding(EdgeInsets(top: 50, leading: 0, bottom: 32, trailing: 0)) // padding 문제 해결해야함
    }
}

#Preview {
    PreviewResultConceptBarGraphView(previewConceptsData: PreviewConceptsData())
}
