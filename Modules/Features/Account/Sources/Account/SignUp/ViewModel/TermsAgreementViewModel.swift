//
//  TermsAgreementViewModel.swift
//  QRIZ
//

import Foundation
import os
import QRIZNetwork

@MainActor
final class TermsAgreementViewModel: ObservableObject {

    // MARK: - Published State

    @Published var terms: [TermItem] = []
    @Published var isSubmitEnabled: Bool = false
    @Published var errorAlert: ErrorAlert?

    struct ErrorAlert: Identifiable {
        let id = UUID()
        let title: String
        let description: String?
    }

    // MARK: - Properties

    private let signUpFlowViewModel: SignUpFlowViewModel
    private let termsService: TermsService
    private let onDismiss: () -> Void
    private let onTermsAgreed: () -> Void
    private let logger = Logger.make(category: "TermsAgreementViewModel")

    // MARK: - Initialization

    init(
        signUpFlowViewModel: SignUpFlowViewModel,
        termsService: TermsService,
        onDismiss: @escaping () -> Void,
        onTermsAgreed: @escaping () -> Void
    ) {
        self.signUpFlowViewModel = signUpFlowViewModel
        self.termsService = termsService
        self.onDismiss = onDismiss
        self.onTermsAgreed = onTermsAgreed
    }

    // MARK: - Methods

    func onAppear() {
        Task { await loadTerms() }
    }

    func dismissTapped() {
        onDismiss()
    }

    func toggleAllTerms() {
        let newState = !terms.allSatisfy(\.isAgreed)
        for index in terms.indices { terms[index].isAgreed = newState }
        updateSubmitState()
    }

    func toggleTerm(at index: Int) {
        guard terms.indices.contains(index) else { return }
        terms[index].isAgreed.toggle()
        updateSubmitState()
    }

    func submitTapped() {
        agreeToTerms()
    }

    // MARK: - Private

    private func loadTerms() async {
        do {
            let response = try await termsService.fetchTerms()
            let privacyPolicy = response.data.first { $0.type == .privacy }

            let ageConfirmation = TermItem(
                kind: .ageConfirmation,
                title: "만 14세 이상",
                documentUrl: privacyPolicy?.documentUrl,
                pdfName: TermItem.bundledPDFName(for: .privacy),
                isAgreed: false
            )
            let serverTerms = response.data.map {
                TermItem(
                    kind: .term(id: $0.id),
                    title: TermItem.displayTitle(for: $0.type),
                    documentUrl: $0.documentUrl,
                    pdfName: TermItem.bundledPDFName(for: $0.type),
                    isAgreed: false
                )
            }

            terms = [ageConfirmation] + serverTerms
        } catch {
            errorAlert = ErrorAlert(title: "약관을 불러오지 못했습니다.", description: "잠시 후 다시 시도해 주세요.")
            logger.error("fetchTerms 실패: \(String(describing: error), privacy: .public)")
        }
    }

    private func updateSubmitState() {
        isSubmitEnabled = terms.allSatisfy(\.isAgreed)
    }

    /// 약관/연령확인 상태를 SignUpFlowViewModel에 저장한다.
    /// 실제 회원가입 API 호출은 플로우 마지막 단계(PasswordInputViewModel)에서 이루어진다.
    private func agreeToTerms() {
        let over14Confirmed = terms.first { $0.kind == .ageConfirmation }?.isAgreed ?? false
        let agreedTermIds = terms.compactMap { $0.isAgreed ? $0.id : nil }

        signUpFlowViewModel.updateOver14Confirmed(over14Confirmed)
        signUpFlowViewModel.updateAgreedTermIds(agreedTermIds)

        onTermsAgreed()
    }
}
