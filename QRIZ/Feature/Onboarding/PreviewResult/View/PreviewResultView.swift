//
//  PreviewResultView.swift
//  QRIZ
//
//  Created by ch on 3/13/25.
//

import SwiftUI
import Combine

struct PreviewResultView: View {
    
    @StateObject var previewScoresData: ResultScoresData
    @StateObject var previewConceptsData: PreviewConceptsData
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack {
                PreviewResultScoreView(previewScoresData: previewScoresData)
                    .background(.white)
                
                Spacer(minLength: 16)
                
                PreviewResultConceptView(previewConceptsData: previewConceptsData)
                    .background(.white)
            }
            .background(previewConceptsData.incorrectCountDataArr.count >= 2 ? .customBlue50 : .white)
        }
        .background(.white)
    }
}

#Preview {
    PreviewResultView(previewScoresData: ResultScoresData(), previewConceptsData: PreviewConceptsData())
}
