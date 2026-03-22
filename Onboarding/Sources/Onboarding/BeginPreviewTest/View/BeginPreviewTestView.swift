import SwiftUI
import DesignSystem

struct BeginPreviewTestView: View {

    // MARK: - Properties

    @ObservedObject var viewModel: BeginPreviewTestViewModel

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            titleSection
            illustrationImage
            Spacer()
            startButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.white)
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Content

private extension BeginPreviewTestView {

    var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("테스트를\n진행해볼까요?")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color.coolNeutral800)

            Text("간단한 프리뷰 테스트로 실력을 점검하고\n이후 맞춤형 개념과 데일리 테스트를 경험해 보세요!")
                .font(.system(size: 16))
                .foregroundColor(Color.coolNeutral500)
                .lineSpacing(4)
        }
        .padding(.top, 100)
        .padding(.horizontal, 24)
    }

    var illustrationImage: some View {
        Image(uiImage: .onboarding2)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
            .padding(.top, 40)
    }

    var startButton: some View {
        Button {
            viewModel.didTapButton()
        } label: {
            Text("간단한 테스트 시작")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.customBlue500)
                .cornerRadius(8)
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 30)
    }
}
