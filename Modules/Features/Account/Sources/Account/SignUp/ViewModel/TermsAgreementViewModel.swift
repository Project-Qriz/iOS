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
        /// 확인 시 약관 화면을 닫아야 하는지 여부
        var endsFlow: Bool = false
    }

    // MARK: - Properties

    private let termsService: TermsService
    private let submitter: TermsAgreementSubmitter
    private let onDismiss: () -> Void
    private var isSubmitting = false
    private let logger = Logger.make(category: "TermsAgreementViewModel")

    // MARK: - Initialization

    init(
        termsService: TermsService,
        submitter: TermsAgreementSubmitter,
        onDismiss: @escaping () -> Void
    ) {
        self.termsService = termsService
        self.submitter = submitter
        self.onDismiss = onDismiss
    }

    // MARK: - Methods

    func onAppear() {
        Task { await loadTerms() }
    }

    func dismissTapped() {
        onDismiss()
    }

    var allAgreed: Bool {
        !terms.isEmpty && terms.allSatisfy(\.isAgreed)
    }

    func toggleAllTerms() {
        let newState = !allAgreed
        for index in terms.indices { terms[index].isAgreed = newState }
        updateSubmitState()
    }

    func toggleTerm(at index: Int) {
        guard terms.indices.contains(index) else { return }
        terms[index].isAgreed.toggle()
        updateSubmitState()
    }

    func submitTapped() {
        guard isSubmitEnabled else { return }
        Task { await agreeToTerms() }
    }

    func errorAlertConfirmed() {
        let endsFlow = errorAlert?.endsFlow ?? false
        errorAlert = nil
        if endsFlow { onDismiss() }
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
            // 클라이언트가 아직 모르는 약관 타입은 표시할 라벨이 없으므로 목록에서 제외한다.
            let serverTerms = response.data.compactMap { item -> TermItem? in
                guard let title = TermItem.displayTitle(for: item.type) else { return nil }
                return TermItem(
                    kind: .term(id: item.id),
                    title: title,
                    documentUrl: item.documentUrl,
                    pdfName: TermItem.bundledPDFName(for: item.type),
                    isAgreed: false
                )
            }

            terms = [ageConfirmation] + serverTerms
            updateSubmitState()
        } catch {
            errorAlert = ErrorAlert(title: "약관을 불러오지 못했습니다.", description: "잠시 후 다시 시도해 주세요.")
            logger.error("fetchTerms 실패: \(String(describing: error), privacy: .public)")
        }
    }

    private func updateSubmitState() {
        isSubmitEnabled = allAgreed && !isSubmitting
    }

    /// 동의 내용을 제출 전략(이메일/소셜 가입)에 넘긴다. 제출 중에는 버튼을 막아 중복 요청을 방지한다.
    private func agreeToTerms() async {
        let agreement = TermsAgreement(
            over14Confirmed: terms.first { $0.kind == .ageConfirmation }?.isAgreed ?? false,
            agreedTermIds: terms.compactMap { $0.isAgreed ? $0.id : nil }
        )

        isSubmitting = true
        updateSubmitState()
        defer {
            isSubmitting = false
            updateSubmitState()
        }

        do {
            try await submitter.submit(agreement)
        } catch let error as TermsAgreementSubmissionError {
            errorAlert = ErrorAlert(title: error.title, description: error.description, endsFlow: error.endsFlow)
        } catch {
            errorAlert = ErrorAlert(title: "약관 동의에 실패했습니다.", description: "잠시 후 다시 시도해 주세요.")
            logger.error("약관 동의 제출 실패: \(String(describing: error), privacy: .public)")
        }
    }
}
