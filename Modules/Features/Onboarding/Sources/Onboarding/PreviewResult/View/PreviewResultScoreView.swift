import SwiftUI
import DesignSystem
import QRIZUtils
import ExamKit

struct PreviewResultScoreView: View {

    // MARK: - Properties

    @ObservedObject var previewScoresData: ResultScoresData
    @State private var isShowingPopover = false

    // MARK: - Body

    var body: some View {
        VStack {
            titleLabel
            Spacer(minLength: 24)
            circularChartSection
            Spacer(minLength: 15)
            scoreRow
            Spacer(minLength: 35)
            subjectScores
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 24)
    }
}

// MARK: - Content

private extension PreviewResultScoreView {

    var titleLabel: some View {
        (
            Text("\(previewScoresData.nickname) 님의\n").font(.system(size: 20, weight: .regular)) +
            Text("프리뷰 결과").font(.system(size: 20, weight: .bold)) +
            Text("에요!").font(.system(size: 20, weight: .regular))
        )
        .foregroundStyle(Color.coolNeutral800)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var circularChartSection: some View {
        ZStack(alignment: .bottom) {
            ResultScoreCircularChartView(resultScoresData: previewScoresData)
                .frame(width: 164, height: 164)
            if isShowingPopover {
                PreviewResultInfoView(onDismiss: { isShowingPopover = false })
            }
        }
    }

    var formattedExpectScore: String {
        formatScore(previewScoresData.expectScore)
    }

    var scoreRow: some View {
        HStack(spacing: 4) {
            Text("예측 점수: \(formattedExpectScore)점")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.coolNeutral700)
            Button {
                isShowingPopover.toggle()
            } label: {
                Image(systemName: "info.circle")
                    .resizable()
                    .frame(width: 13, height: 13)
                    .foregroundStyle(Color.coolNeutral300)
            }
        }
    }

    var subjectScores: some View {
        VStack {
            SingleSubjectView(
                circleColor: Color.customBlue800,
                subjectText: "데이터 모델링의 이해",
                score: previewScoresData.subjectScores[0]
            )
            Divider()
                .overlay(Color.coolNeutral200)
            SingleSubjectView(
                circleColor: Color.customBlue500,
                subjectText: "SQL 기본 및 활용",
                score: previewScoresData.subjectScores[1]
            )
        }
    }
}

// MARK: - Methods

private extension PreviewResultScoreView {

    func formatScore(_ score: CGFloat) -> String {
        score.truncatingRemainder(dividingBy: 1) == 0 ?
        String(format: "%.0f", score) :
        String(format: "%.1f", score)
    }
}

#Preview {
    PreviewResultScoreView(previewScoresData: ResultScoresData())
}
