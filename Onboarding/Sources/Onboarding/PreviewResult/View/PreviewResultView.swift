import SwiftUI
import DesignSystem
import Combine
import QRIZUtils

struct PreviewResultView: View {

    @ObservedObject var previewScoresData: ResultScoresData
    @ObservedObject var previewConceptsData: PreviewConceptsData

    var body: some View {
        ScrollView(.vertical) {
            LazyVStack {
                PreviewResultScoreView(previewScoresData: previewScoresData)
                    .background(.white)

                Spacer(minLength: 16)

                PreviewResultConceptView(previewConceptsData: previewConceptsData)
                    .background(.white)
            }
            .background(previewConceptsData.incorrectCountDataArr.count >= 2 ? Color.customBlue50 : .white)
        }
        .background(.white)
    }
}

#Preview {
    PreviewResultView(previewScoresData: ResultScoresData(), previewConceptsData: PreviewConceptsData())
}
