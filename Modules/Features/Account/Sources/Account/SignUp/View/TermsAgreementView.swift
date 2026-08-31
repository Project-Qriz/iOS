//
//  TermsAgreementView.swift
//  QRIZ
//

import SwiftUI
import DesignSystem

struct TermsAgreementView: View {
    @ObservedObject var viewModel: TermsAgreementViewModel
    let onShowTermsDetail: (TermItem) -> Void

    var body: some View {
        VStack(spacing: 0) {
            TermsAgreementHeaderView(progress: 0.2, onDismiss: viewModel.dismissTapped)

            TermsAgreementIntroView()
                .padding(.top, 40)
                .padding(.horizontal, 32)

            Spacer()

            VStack(alignment: .leading, spacing: 28) {
                TermsAgreementAllAgreeRowView(
                    isChecked: viewModel.allAgreed,
                    onTap: viewModel.toggleAllTerms
                )

                VStack(alignment: .leading, spacing: 28) {
                    ForEach(Array(viewModel.terms.enumerated()), id: \.offset) { index, term in
                        let isAgeConfirmation = term.kind == .ageConfirmation
                        TermsAgreementItemRowView(
                            title: term.title,
                            isChecked: term.isAgreed,
                            showsChevron: !isAgeConfirmation,
                            onToggle: { viewModel.toggleTerm(at: index) },
                            onDetailTap: { onShowTermsDetail(term) }
                        )
                    }
                }
            }
            .padding(.horizontal, 32)

            Button(action: viewModel.submitTapped) {
                Text("약관 동의하기")
                    .font(.system(size: 16, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(viewModel.isSubmitEnabled ? Color.customBlue500 : Color.coolNeutral200)
                    .foregroundColor(viewModel.isSubmitEnabled ? .white : Color.coolNeutral500)
                    .cornerRadius(8)
            }
            .disabled(!viewModel.isSubmitEnabled)
            .padding(.horizontal, 32)
            .padding(.top, 42)
            .padding(.bottom, 32)
        }
        .background(Color.white)
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
