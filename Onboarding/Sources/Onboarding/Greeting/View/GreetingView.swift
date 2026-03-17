import SwiftUI
import DesignSystem

struct GreetingView: View {
    @ObservedObject var viewModel: GreetingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("\(viewModel.nickname)님\n환영합니다")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color(.coolNeutral800))
                .padding(.top, 40)
                .padding(.horizontal, 24)

            Text("준비되어 있는 오늘의 공부와, 모의고사로\n시험을 같이 준비해봐요!")
                .font(.system(size: 16))
                .foregroundColor(Color(.coolNeutral500))
                .lineSpacing(4)
                .padding(.top, 12)
                .padding(.horizontal, 24)

            Image(uiImage: .onboarding3)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .padding(.top, 40)

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
