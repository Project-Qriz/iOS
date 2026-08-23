import Foundation
import os
import QRIZNetwork

@MainActor
final class ConsentsViewModel: ObservableObject {

    // MARK: - Published State

    @Published var terms: [TermItem] = []
    @Published var showsAgeSection: Bool = false
    @Published var ageConfirmed: Bool = true
    @Published var isSubmitEnabled: Bool = false
    @Published var errorAlert: ErrorAlert?
    @Published var showAgeReconfirmAlert: Bool = false

    struct ErrorAlert: Identifiable {
        let id = UUID()
        let title: String
        let description: String?
    }

    // MARK: - Properties

    private let termsService: TermsService
    private let consentsService: ConsentsService
    private let myPageService: MyPageService
    private let accessTokenProvider: () -> String?
    private let reAgreementRequired: Bool
    private let ageVerificationRequired: Bool
    private let onComplete: () -> Void
    private let onAccountDestroyed: () -> Void
    private let logger = Logger.make(category: "ConsentsViewModel")

    // MARK: - Initialization

    init(
        termsService: TermsService,
        consentsService: ConsentsService,
        myPageService: MyPageService,
        accessTokenProvider: @escaping () -> String?,
        reAgreementRequired: Bool,
        ageVerificationRequired: Bool,
        onComplete: @escaping () -> Void,
        onAccountDestroyed: @escaping () -> Void
    ) {
        self.termsService = termsService
        self.consentsService = consentsService
        self.myPageService = myPageService
        self.accessTokenProvider = accessTokenProvider
        self.reAgreementRequired = reAgreementRequired
        self.ageVerificationRequired = ageVerificationRequired
        self.onComplete = onComplete
        self.onAccountDestroyed = onAccountDestroyed
        self.showsAgeSection = ageVerificationRequired
        self.ageConfirmed = !ageVerificationRequired
    }

    // MARK: - Methods

    func onAppear() {
        Task { await loadTerms() }
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

    func toggleAgeConfirmation() {
        ageConfirmed.toggle()
        updateSubmitState()
    }

    func submitTapped() {
        guard ageConfirmed else {
            showAgeReconfirmAlert = true
            return
        }
        Task { await submit() }
    }

    func ageReconfirmationConfirmed() {
        ageConfirmed = true
        Task { await submit() }
    }

    func ageReconfirmationDenied() {
        Task { await destroyAccount() }
    }

    // MARK: - Private

    private func loadTerms() async {
        guard reAgreementRequired else {
            updateSubmitState()
            return
        }
        do {
            let response = try await termsService.fetchTerms()
            terms = response.data.map {
                TermItem(kind: .term(id: $0.id), title: $0.title, documentUrl: $0.documentUrl, isAgreed: false)
            }
            updateSubmitState()
        } catch {
            errorAlert = ErrorAlert(title: "약관을 불러오지 못했습니다.", description: "잠시 후 다시 시도해 주세요.")
            logger.error("fetchTerms 실패: \(String(describing: error), privacy: .public)")
        }
    }

    private func updateSubmitState() {
        let termsSatisfied = reAgreementRequired ? terms.allSatisfy(\.isAgreed) : true
        isSubmitEnabled = termsSatisfied && ageConfirmed
    }

    private func submit() async {
        guard let accessToken = accessTokenProvider() else {
            errorAlert = ErrorAlert(title: "로그인이 만료되었습니다.", description: "다시 로그인해 주세요.")
            return
        }
        let agreedTermIds = reAgreementRequired ? terms.compactMap { $0.isAgreed ? $0.id : nil } : []

        do {
            let response = try await consentsService.submitConsents(
                accessToken: accessToken,
                over14Confirmed: ageConfirmed,
                agreedTermIds: agreedTermIds
            )
            if response.data.reAgreementRequired == false && response.data.ageVerificationRequired == false {
                onComplete()
            } else {
                errorAlert = ErrorAlert(title: "동의가 완료되지 않았습니다.", description: "모든 항목에 동의해 주세요.")
            }
        } catch {
            errorAlert = ErrorAlert(title: "제출에 실패했습니다.", description: "잠시 후 다시 시도해 주세요.")
            logger.error("submitConsents 실패: \(String(describing: error), privacy: .public)")
        }
    }

    private func destroyAccount() async {
        do {
            _ = try await myPageService.deleteAccount()
        } catch {
            logger.error("계정 파기 실패: \(String(describing: error), privacy: .public)")
        }
        onAccountDestroyed()
    }
}
