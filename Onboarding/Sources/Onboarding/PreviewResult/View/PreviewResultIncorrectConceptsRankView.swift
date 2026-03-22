import SwiftUI
import QRIZUtils

struct PreviewResultIncorrectConceptsRankView: View {

    // MARK: - Properties

    @ObservedObject var previewConceptsData: PreviewConceptsData

    // MARK: - Body

    var body: some View {
        VStack(spacing: 16) {
            ForEach(previewConceptsData.incorrectCountDataArr.prefix(3)) { item in
                PreviewResultIncorrectRankView(
                    rank: item.id,
                    topic: item.topic,
                    incorrectNum: item.incorrectCount
                )
            }
        }
    }
}

#Preview {
    PreviewResultIncorrectConceptsRankView(previewConceptsData: PreviewConceptsData(
        totalQuestions: 20,
        incorrectCountDataArr: [
            IncorrectCountData(id: 1, incorrectCount: 5, topic: ["DDL"]),
            IncorrectCountData(id: 2, incorrectCount: 3, topic: ["조인"]),
            IncorrectCountData(id: 3, incorrectCount: 1, topic: ["모델이 표현하는 트랜잭션의 이해"]),
        ],
        firstConcept: "",
        secondConcept: ""
    ))
}
