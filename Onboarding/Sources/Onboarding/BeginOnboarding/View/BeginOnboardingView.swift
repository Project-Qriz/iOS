import SwiftUI
import DesignSystem

struct BeginOnboardingView: View {
    @ObservedObject var viewModel: BeginOnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("SQLD를 어느정도\n알고 계신가요?")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color(.coolNeutral800))
                .padding(.top, 50)
                .padding(.horizontal, 24)

            Text("선택하신 체크사항을 기반으로\n맞춤 프리뷰 테스트를 제공해 드려요!")
                .font(.system(size: 16))
                .foregroundColor(Color(.coolNeutral500))
                .lineSpacing(4)
                .padding(.top, 8)
                .padding(.horizontal, 24)

            Image(uiImage: .onboarding1)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .padding(.top, 40)

            Spacer()

            Button {
                viewModel.didTapButton()
            } label: {
                Text("시작하기")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color(.customBlue500))
                    .cornerRadius(8)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.white)
        .toolbar(.hidden, for: .navigationBar)
    }
}
