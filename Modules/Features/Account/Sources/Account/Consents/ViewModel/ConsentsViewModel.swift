import Foundation
import os
import QRIZNetwork

@MainActor
final class ConsentsViewModel: ObservableObject {

    // MARK: - Published State

    @Published var terms: [TermItem] = []
    /// 약관 체크리스트 섹션 노출 여부.
    /// `terms`는 재동의가 필요 없을 때도(기존 동의 id를 제출에 실어 보내기 위해) 채워지므로,
    /// UI 노출 판단은 `terms.isEmpty`가 아니라 반드시 이 값으로 한다.
    @Published var showsTermsSection: Bool = false
    @Published var showsAgeSection: Bool = false
    @Published var ageConfirmed: Bool = true
    @Published var isSubmitEnabled: Bool = false
    @Published var errorAlert: ErrorAlert?
    @Published var showAgeReconfirmAlert: Bool = false

    struct ErrorAlert: Identifiable {
        let id = UUID()
        let title: String
        let description: String?
        /// 약관 목록 재조회로 복구 가능한 에러인지 여부.
        /// 제출 실패는 여기서 재조회하면 사용자가 체크한 상태가 날아가므로 false로 두고,
        /// 제출 버튼을 다시 눌러 재시도하게 한다.
        let canRetryLoad: Bool

        init(title: String, description: String? = nil, canRetryLoad: Bool = false) {
            self.title = title
            self.description = description
            self.canRetryLoad = canRetryLoad
        }
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
    private let onDeclined: () -> Void
    private let logger = Logger.make(category: "ConsentsViewModel")

    /// `onAppear`가 재진입(약관 상세 모달 표시 후 복귀 등)할 때 이미 토글한 체크가 초기화되지 않도록 하는 가드.
    private var hasLoadedTerms = false
    /// 약관 목록 fetch 성공 여부. 실패해 목록이 비어 있는 상태로 제출되는 것을 막는다.
    private var termsFetchSucceeded = false

    // MARK: - Initialization

    init(
        termsService: TermsService,
        consentsService: ConsentsService,
        myPageService: MyPageService,
        accessTokenProvider: @escaping () -> String?,
        reAgreementRequired: Bool,
        ageVerificationRequired: Bool,
        onComplete: @escaping () -> Void,
        onAccountDestroyed: @escaping () -> Void,
        onDeclined: @escaping () -> Void
    ) {
        self.termsService = termsService
        self.consentsService = consentsService
        self.myPageService = myPageService
        self.accessTokenProvider = accessTokenProvider
        self.reAgreementRequired = reAgreementRequired
        self.ageVerificationRequired = ageVerificationRequired
        self.onComplete = onComplete
        self.onAccountDestroyed = onAccountDestroyed
        self.onDeclined = onDeclined
        self.showsTermsSection = reAgreementRequired
        self.showsAgeSection = ageVerificationRequired
        self.ageConfirmed = !ageVerificationRequired
    }

    // MARK: - Methods

    func onAppear() {
        guard !hasLoadedTerms else { return }
        hasLoadedTerms = true
        Task { await loadTerms() }
    }

    /// 사용자가 에러 알럿에서 명시적으로 재시도한 경우 — `hasLoadedTerms` 가드를 우회한다.
    func retryLoadTerms() {
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

    /// 재동의를 거부하고 로그아웃한다 — 계정 파기가 아니다(파기는 만 14세 미만 확정 경로 전용).
    func declineTapped() {
        onDeclined()
    }

    // MARK: - Private

    /// 재동의 필요 여부와 무관하게 항상 약관 목록을 조회한다.
    /// 재동의가 필요 없는 경우에도 "기존에 동의한 약관 id"를 제출 payload에 그대로 실어 보내야 하는데,
    /// 클라이언트가 그 id를 알 방법이 `GET /api/terms` 조회밖에 없기 때문이다.
    private func loadTerms() async {
        do {
            let response = try await termsService.fetchTerms()
            terms = response.data.map {
                TermItem(
                    kind: .term(id: $0.id),
                    title: TermItem.displayTitle(for: $0.type),
                    documentUrl: $0.documentUrl,
                    pdfName: TermItem.bundledPDFName(for: $0.type),
                    // 재동의가 필요하면 사용자가 직접 체크해야 하고,
                    // 필요 없으면 이미 유효하게 동의된 상태이므로 미리 체크해 둔다.
                    isAgreed: !reAgreementRequired
                )
            }
            termsFetchSucceeded = true
            updateSubmitState()
        } catch {
            termsFetchSucceeded = false
            updateSubmitState()
            errorAlert = ErrorAlert(
                title: "약관을 불러오지 못했습니다.",
                description: "잠시 후 다시 시도해 주세요.",
                canRetryLoad: true
            )
            logger.error("fetchTerms 실패: \(String(describing: error), privacy: .public)")
        }
    }

    private func updateSubmitState() {
        isSubmitEnabled = termsFetchSucceeded && terms.allSatisfy(\.isAgreed) && ageConfirmed
    }

    private func submit() async {
        guard let accessToken = accessTokenProvider() else {
            errorAlert = ErrorAlert(title: "로그인이 만료되었습니다.", description: "다시 로그인해 주세요.")
            return
        }
        let agreedTermIds = terms.compactMap { $0.isAgreed ? $0.id : nil }

        do {
            let response = try await consentsService.submitConsents(
                accessToken: accessToken,
                over14Confirmed: ageConfirmed,
                agreedTermIds: agreedTermIds
            )
            if response.data.reAgreementRequired == false && response.data.ageVerificationRequired == false {
                onComplete()
            } else {
                // 서버가 제출을 받고도 플래그를 그대로 내려준 경우 — 클라이언트 상태만으로는 원인을 알 수 없으므로
                // "모든 항목에 동의해 주세요" 같은 단정 대신 재시도를 안내한다(제출 버튼으로 그대로 재시도 가능).
                errorAlert = ErrorAlert(title: "제출이 완료되지 않았습니다.", description: "다시 시도해 주세요.")
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
