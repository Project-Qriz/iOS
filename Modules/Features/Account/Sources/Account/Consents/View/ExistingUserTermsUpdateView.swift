import SwiftUI
import DesignSystem
import QRIZUtils

/// 홈 화면 위에 dim 배경과 함께 하단에 붙는 바텀시트 스타일 약관 업데이트 확인 팝업.
struct ExistingUserTermsUpdateView: View {
    @ObservedObject var viewModel: ExistingUserTermsUpdateViewModel
    let onShowTermsDetail: (TermItem) -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(uiImage: .appIconLogo)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 56, height: 56)

                    VStack(spacing: 8) {
                        Text("서비스 이용약관이 업데이트됐어요")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color.coolNeutral800)
                            .multilineTextAlignment(.center)

                        Text("만 14세 이상 이용자 확인이 필요합니다.\n계속 이용하시려면 아래 내용에 동의해주세요.")
                            .font(.system(size: 14))
                            .foregroundColor(Color.coolNeutral500)
                            .multilineTextAlignment(.center)
                    }
                }

                VStack(alignment: .leading, spacing: 16) {
                    TermsAgreementItemRowView(
                        title: "만 14세 이상",
                        isChecked: viewModel.ageConfirmed,
                        showsChevron: false,
                        onToggle: viewModel.toggleAge,
                        onDetailTap: {}
                    )

                    TermsAgreementItemRowView(
                        title: "개인정보 처리방침",
                        isChecked: viewModel.privacyAgreed,
                        showsChevron: true,
                        onToggle: viewModel.togglePrivacy,
                        onDetailTap: {
                            if let term = viewModel.privacyTerm {
                                onShowTermsDetail(term)
                            }
                        }
                    )
                }

                Button(action: viewModel.submitTapped) {
                    Text("동의하고 계속하기")
                        .font(.system(size: 16, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(viewModel.isSubmitEnabled ? Color.customBlue500 : Color.coolNeutral200)
                        .foregroundColor(viewModel.isSubmitEnabled ? .white : Color.coolNeutral500)
                        .cornerRadius(8)
                }
                .disabled(!viewModel.isSubmitEnabled)
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
            .padding(.bottom, 24)
            .frame(maxWidth: .infinity)
            .background(
                Color.white
                    .cornerRadius(24, corners: [.topLeft, .topRight])
                    .ignoresSafeArea(edges: .bottom)
            )
        }
        .onAppear { viewModel.onAppear() }
        .alert(
            viewModel.errorAlert?.title ?? "",
            isPresented: Binding(
                get: { viewModel.errorAlert != nil },
                set: { if !$0 { viewModel.errorAlert = nil } }
            )
        ) {
            Button("확인", role: .cancel) { viewModel.errorAlert = nil }
        } message: {
            if let description = viewModel.errorAlert?.description {
                Text(description)
            }
        }
    }
}
