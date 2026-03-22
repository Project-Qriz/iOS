import SwiftUI
import DesignSystem

struct BeginOnboardingView: View {

    // MARK: - Properties

    @ObservedObject var viewModel: BeginOnboardingViewModel

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

private extension BeginOnboardingView {

    var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("SQLD를 어느정도\n알고 계신가요?")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color.coolNeutral800)

            Text("선택하신 체크사항을 기반으로\n맞춤 프리뷰 테스트를 제공해 드려요!")
                .font(.system(size: 16))
                .foregroundColor(Color.coolNeutral500)
                .lineSpacing(4)
        }
        .padding(.top, 50)
        .padding(.horizontal, 24)
    }

    var illustrationImage: some View {
        Image(uiImage: .onboarding1)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
            .padding(.top, 40)
    }

    var startButton: some View {
        Button {
            viewModel.didTapButton()
        } label: {
            Text("시작하기")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.customBlue500)
                .cornerRadius(8)
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 16)
    }
}
