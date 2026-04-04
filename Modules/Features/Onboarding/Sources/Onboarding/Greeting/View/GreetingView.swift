import SwiftUI
import DesignSystem

struct GreetingView: View {

    // MARK: - Properties

    @ObservedObject var viewModel: GreetingViewModel

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            titleSection
            illustrationImage
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            viewModel.onAppear()
        }
    }
}

// MARK: - Content

private extension GreetingView {

    var titleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(viewModel.nickname)님\n환영합니다")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color.coolNeutral800)

            Text("준비되어 있는 오늘의 공부와, 모의고사로\n시험을 같이 준비해봐요!")
                .font(.system(size: 16))
                .foregroundColor(Color.coolNeutral500)
                .lineSpacing(4)
        }
        .padding(.top, 40)
        .padding(.horizontal, 24)
    }

    var illustrationImage: some View {
        Image(uiImage: .onboarding3)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
            .padding(.top, 40)
    }
}
