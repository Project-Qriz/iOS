//
//  PreviewResultView.swift
//  QRIZ
//
//  Created by ch on 3/13/25.
//

import SwiftUI

struct PreviewResultView: View {
    
    @StateObject var previewScoresData: PreviewScoresData
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
        }
    }
}

#Preview {
    PreviewResultView(previewScoresData: PreviewScoresData(), previewConceptsData: PreviewConceptsData())
}
