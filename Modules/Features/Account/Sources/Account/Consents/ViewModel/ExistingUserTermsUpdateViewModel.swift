import Foundation
import os
import QRIZNetwork

/// 기존 가입자가 앱 재실행(스플래시→홈) 시 홈 화면 위 팝업으로 보는 약관 업데이트 확인 화면의 ViewModel.
///
/// 전체화면 `ConsentsViewModel`과 달리 화면에는 연령확인/개인정보 처리방침 두 항목만 노출한다.
/// 화면에 노출하지 않는 나머지 약관(서비스 이용약관 등)은 사용자에게 다시 묻지 않고
/// 제출 시 자동으로 동의 처리해 함께 전송한다.
@MainActor
final class ExistingUserTermsUpdateViewModel: ObservableObject {

    // MARK: - Published State

    @Published var ageConfirmed: Bool = false
    @Published var privacyAgreed: Bool = false
    @Published var isSubmitEnabled: Bool = false
    @Published var privacyTerm: TermItem?
    @Published var errorAlert: ErrorAlert?

    struct ErrorAlert: Identifiable {
        let id = UUID()
        let title: String
        let description: String?
    }

    // MARK: - Properties

    private let termsService: TermsService
    private let consentsService: ConsentsService
    private let accessTokenProvider: () -> String?
    private let onComplete: () -> Void
    private let logger = Logger.make(category: "ExistingUserTermsUpdateViewModel")

    /// 제출 시 함께 보내야 하는 전체 약관 목록(화면에는 일부만 노출).
    private var allTerms: [TermsListItem] = []
    private var hasLoadedTerms = false

    // MARK: - Initialization

    init(
        termsService: TermsService,
        consentsService: ConsentsService,
        accessTokenProvider: @escaping () -> String?,
        onComplete: @escaping () -> Void
    ) {
        self.termsService = termsService
        self.consentsService = consentsService
        self.accessTokenProvider = accessTokenProvider
        self.onComplete = onComplete
    }

    // MARK: - Methods

    func onAppear() {
        guard !hasLoadedTerms else { return }
        hasLoadedTerms = true
        Task { await loadTerms() }
    }

    func toggleAge() {
        ageConfirmed.toggle()
        updateSubmitState()
    }

    func togglePrivacy() {
        privacyAgreed.toggle()
        updateSubmitState()
    }

    func submitTapped() {
        Task { await submit() }
    }

    // MARK: - Private

    private func loadTerms() async {
        do {
            let response = try await termsService.fetchTerms()
            allTerms = response.data
            if let privacy = response.data.first(where: { $0.type == .privacy }) {
                privacyTerm = TermItem(
                    kind: .term(id: privacy.id),
                    title: TermItem.displayTitle(for: .privacy),
                    documentUrl: privacy.documentUrl,
                    pdfName: TermItem.bundledPDFName(for: .privacy),
                    isAgreed: false
                )
            }
            updateSubmitState()
        } catch {
            errorAlert = ErrorAlert(title: "약관을 불러오지 못했습니다.", description: "잠시 후 다시 시도해 주세요.")
            logger.error("fetchTerms 실패: \(String(describing: error), privacy: .public)")
        }
    }

    private func updateSubmitState() {
        isSubmitEnabled = !allTerms.isEmpty && ageConfirmed && privacyAgreed
    }

    /// 화면에 노출하지 않는 약관(서비스 이용약관 등)은 자동 동의로 포함하고,
    /// 개인정보 처리방침은 사용자가 실제로 체크한 경우에만 포함한다.
    private func submit() async {
        guard let accessToken = accessTokenProvider() else {
            errorAlert = ErrorAlert(title: "로그인이 만료되었습니다.", description: "다시 로그인해 주세요.")
            return
        }
        let agreedTermIds = allTerms.compactMap { term -> Int? in
            term.type == .privacy ? (privacyAgreed ? term.id : nil) : term.id
        }

        do {
            _ = try await consentsService.submitConsents(
                accessToken: accessToken,
                over14Confirmed: ageConfirmed,
                agreedTermIds: agreedTermIds
            )
            onComplete()
        } catch {
            errorAlert = ErrorAlert(title: "제출에 실패했습니다.", description: "잠시 후 다시 시도해 주세요.")
            logger.error("submitConsents 실패: \(String(describing: error), privacy: .public)")
        }
    }
}
