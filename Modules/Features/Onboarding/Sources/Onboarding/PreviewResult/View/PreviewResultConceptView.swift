import SwiftUI
import DesignSystem
import QRIZUtils

struct PreviewResultConceptView: View {

    // MARK: - Properties

    @ObservedObject var previewConceptsData: PreviewConceptsData

    // MARK: - Body

    var body: some View {
        VStack {
            if previewConceptsData.numOfChartToPresent > 0 {
                chartSection
            }
            recommendConceptsSection
        }
        .background(.white)
        .padding(.horizontal, 18)
        .padding(.vertical, 24)
    }
}

// MARK: - Content

private extension PreviewResultConceptView {

    var chartSection: some View {
        VStack {
            chartTitle
            Spacer(minLength: 16)
            totalQuestionsLabel
            Spacer(minLength: 20)
            if previewConceptsData.incorrectCountDataArr.count >= 2 {
                PreviewResultBarGraphsView(previewConceptsData: previewConceptsData)
            }
            Spacer(minLength: 16)
            PreviewResultIncorrectConceptsRankView(previewConceptsData: previewConceptsData)
            Spacer(minLength: 32)
        }
    }

    var chartTitle: some View {
        (
            Text("틀린 문제").font(.system(size: 20, weight: .bold)) +
            Text("에\n").font(.system(size: 20, weight: .medium)) +
            Text("자주 등장하는 개념").font(.system(size: 20, weight: .bold))
        )
        .foregroundStyle(Color.coolNeutral800)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var totalQuestionsLabel: some View {
        (
            Text("총 문제 개수: ").font(.system(size: 12, weight: .regular)) +
            Text("\(previewConceptsData.totalQuestions)개").font(.system(size: 12, weight: .medium))
        )
        .foregroundStyle(Color.coolNeutral400)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var recommendConceptsSection: some View {
        VStack {
            Text("보충하면 좋은 개념 top2")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(Color.coolNeutral700)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing: 8) {
                conceptCard(text: previewConceptsData.firstConcept)
                conceptCard(text: previewConceptsData.secondConcept)
            }
        }
    }

    func conceptCard(text: String) -> some View {
        Rectangle()
            .cornerRadius(12, corners: .allCorners)
            .frame(height: 70)
            .foregroundStyle(Color.customBlue50)
            .overlay(alignment: .leading) {
                Text(text)
                    .font(.system(size: 20, weight: .bold))
                    .padding(.horizontal, 24)
                    .foregroundStyle(Color.coolNeutral700)
            }
    }
}

#Preview {
    PreviewResultConceptView(previewConceptsData: PreviewConceptsData())
}
