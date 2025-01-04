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
                BarGraphsView()
                    .environmentObject(previewConceptsData)
            }
            
            Spacer()
            
            IncorrectConceptsRankView()
                .environmentObject(previewConceptsData)
            
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
        .padding(EdgeInsets(top: 50, leading: 50, bottom: 50, trailing: 50))
    }
}

#Preview {
    ConceptBarGraphView(previewConceptsData: PreviewConceptsData())
}
