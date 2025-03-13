//
//  ConceptBarGraphView.swift
//  QRIZ
//
//  Created by ch on 12/29/24.
//

import SwiftUI

struct PreviewResultConceptView: View {
    
    @ObservedObject var previewConceptsData: PreviewConceptsData
    
    private var hasMultipleIncorrectConcepts: Bool {
        previewConceptsData.incorrectCountDataArr.count > 1
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("틀린 문제에\n자주 등장하는 개념")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.coolNeutral800)
                Spacer()
            }
            
            Spacer(minLength: 16)
            
            HStack {
                Text("총 문제 개수: 20개")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.coolNeutral500)
                Spacer()
            }
            
            Spacer(minLength: 20)
            
            if hasMultipleIncorrectConcepts {
                PreviewResultBarGraphsView(previewConceptsData: previewConceptsData)
            } else {
                Text("하나의 개념만 틀린 경우\n틀린 개념과 문제 개수만 보입니다.")
                    .font(.system(size: 14))
                    .foregroundStyle(.coolNeutral500)
                    .multilineTextAlignment(.center)
            }
            
            Spacer(minLength: 16)
            
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
            
            Spacer(minLength: 32)
            
            HStack {
                Text("보충하면 좋은 개념 top2")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.coolNeutral700)
                Spacer()
            }
            
            HStack(spacing: 8) {
                ForEach(0..<2) { idx in
                    Rectangle()
                        .cornerRadius(12, corners: .allCorners)
                        .frame(height: 70)
                        .foregroundStyle(.customBlue50)
                        .overlay(alignment: .leading) {
                            Text(idx == 0 ? "\(previewConceptsData.firstConcept)" : "\(previewConceptsData.secondConcept)")
                                .font(.system(size: 20, weight: .bold))
                                .padding([.leading, .trailing], 24)
                                .foregroundStyle(.coolNeutral700)
                        }
                }
            }
        }
        .background(.white)
        .padding(EdgeInsets(top: 24, leading: 18, bottom: 24, trailing: 18))
    }
}

#Preview {
    PreviewResultConceptView(previewConceptsData: PreviewConceptsData())
}
