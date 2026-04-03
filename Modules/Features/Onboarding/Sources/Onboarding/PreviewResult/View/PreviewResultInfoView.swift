import SwiftUI
import DesignSystem

struct PreviewResultInfoView: View {

    // MARK: - Properties

    let onDismiss: () -> Void

    // MARK: - Body

    var body: some View {
        VStack {
            header
            Spacer()
            descriptionSection
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.coolNeutral200, lineWidth: 2)
        )
        .frame(width: 250, height: 150)
        .background(.white)
    }
}

// MARK: - Content

private extension PreviewResultInfoView {

    var header: some View {
        HStack {
            Text("예측 점수란?")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.coolNeutral800)
            Spacer(minLength: 13)
            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark")
                    .frame(width: 8, height: 8)
                    .foregroundStyle(Color.coolNeutral300)
            }
        }
    }

    var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("출제 경향을 반영한 가중치를 적용하여, 예상한 점수입니다.")
            Text("* 실제 시험에서는 난이도나 변동 요소에 따라 점수가 달라질 수 있습니다.")
        }
        .font(.system(size: 12, weight: .medium))
        .foregroundStyle(Color.coolNeutral500)
    }
}

#Preview {
    PreviewResultInfoView(onDismiss: {})
}
