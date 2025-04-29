//
//  ConceptBarGraphView.swift
//  QRIZ
//
//  Created by ch on 12/29/24.
//

import SwiftUI

struct PreviewResultConceptView: View {
    
    @ObservedObject var previewConceptsData: PreviewConceptsData
    
    var body: some View {
        VStack {
            if previewConceptsData.numOfTotalConcept > 1 {
                HStack {
                    Text("틀린 문제").font(.system(size: 20, weight: .bold)) +
                    Text("에\n").font(.system(size: 20, weight: .medium)) +
                    Text("자주 등장하는 개념").font(.system(size: 20, weight: .bold))
                    
                    Spacer()
                }
                .foregroundStyle(.coolNeutral800)
                
                Spacer(minLength: 16)
                
                HStack {
                    Text("총 문제 개수: ").font(.system(size: 12, weight: .regular)) +
                    Text("\(previewConceptsData.totalQuestions)개").font(.system(size: 12, weight: .medium))
                    
                    Spacer()
                }
                .foregroundStyle(.coolNeutral400)
                
                Spacer(minLength: 20)
                
                if previewConceptsData.incorrectCountDataArr.count >= 2 {
                    PreviewResultBarGraphsView(previewConceptsData: previewConceptsData)
                }
                
                Spacer(minLength: 16)
                
                PreviewResultIncorrectConceptsRankView(previewConceptsData: previewConceptsData)
                
                Spacer(minLength: 32)
            }
            
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
