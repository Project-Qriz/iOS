import SwiftUI
import DesignSystem

struct ConsentsView: View {
    @ObservedObject var viewModel: ConsentsViewModel
    let onShowTermsDetail: (TermItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(viewModel.showsAgeSection ? "약관 재동의 및 연령 확인" : "약관 재동의")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color.coolNeutral800)

            if viewModel.showsAgeSection {
                AgeConfirmationRowView(
                    isChecked: viewModel.ageConfirmed,
                    onToggle: viewModel.toggleAgeConfirmation
                )
            }

            if !viewModel.terms.isEmpty {
                VStack(spacing: 16) {
                    AllAgreeRowView(
                        isChecked: viewModel.terms.allSatisfy(\.isAgreed),
                        onTap: viewModel.toggleAllTerms
                    )

                    ForEach(Array(viewModel.terms.enumerated()), id: \.offset) { index, term in
                        TermRowView(
                            title: term.title,
                            isChecked: term.isAgreed,
                            onToggle: { viewModel.toggleTerm(at: index) },
                            onDetailTap: { onShowTermsDetail(term) }
                        )
                    }
                }
            }

            Spacer()

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
        .padding(.horizontal, 32)
        .padding(.top, 24)
        .background(Color.white)
        .onAppear { viewModel.onAppear() }
        .interactiveDismissDisabled(true)
        .alert(
            "다시 확인해 주세요",
            isPresented: $viewModel.showAgeReconfirmAlert
        ) {
            Button("만 14세 이상이 맞아요") { viewModel.ageReconfirmationConfirmed() }
            Button("만 14세 미만이 맞아요", role: .destructive) { viewModel.ageReconfirmationDenied() }
        } message: {
            Text("만 14세 미만은 이용하실 수 없어요.\n실수로 선택하셨다면 다시 확인해 주세요.")
        }
        .alert(
            viewModel.errorAlert?.title ?? "",
            isPresented: Binding(
                get: { viewModel.errorAlert != nil },
                set: { if !$0 { viewModel.errorAlert = nil } }
            )
        ) {
            Button("확인") { viewModel.errorAlert = nil }
        } message: {
            if let description = viewModel.errorAlert?.description {
                Text(description)
            }
        }
    }
}
