import Foundation
import Combine
import os
import QRIZNetwork
import Account
import QRIZUtils

@MainActor
final class MyPageViewModel {

    // MARK: - Properties

    private let userName: String
    private let myPageService: any MyPageService
    private let termsService: any TermsService
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger.make(category: "MyPageViewModel")

    // MARK: - Initialization

    private let analyticsService: any AnalyticsService

    init(
        userName: String,
        myPageService: any MyPageService,
        termsService: any TermsService,
        analyticsService: any AnalyticsService = AnalyticsManager.shared
    ) {
        self.userName = userName
        self.myPageService = myPageService
        self.termsService = termsService
        self.analyticsService = analyticsService
    }

    // MARK: - Methods

    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink { [weak self] event in
                guard let self else { return }
                switch event {
                case .viewDidLoad:
                    analyticsService.log(.screenView(.myPage))
                    self.fetchVersion()

                case .didTapProfile:
                    self.outputSubject.send(.navigateToSettingsView)

                case .didTapResetPlan:
                    self.outputSubject.send(.showResetAlert)

                case .didConfirmResetPlan:
                    Task { await self.performReset() }

                case .didTapRegisterExam:
                    self.outputSubject.send(.showExamSchedule)

                case .didTapTermsOfService:
                    Task { await self.showTermsDetail(matching: "이용약관") }

                case .didTapPrivacyPolicy:
                    Task { await self.showTermsDetail(matching: "개인정보") }
                }
            }
            .store(in: &cancellables)

        return outputSubject.eraseToAnyPublisher()
    }

    private func fetchVersion() {
        Task {
            do {
                let version = try await myPageService.fetchVersion()
                outputSubject.send(.setupView(userName: userName, version: version.data.versionInfo))

            } catch let error as NetworkError {
                outputSubject.send(.setupView(userName: userName, version: "0.0.0"))
                logger.error("NetworkError(fetchVersion): \(error.debugDescription, privacy: .public)")

            } catch {
                outputSubject.send(.setupView(userName: userName, version: "0.0.0"))
                logger.error("Unhandled error(fetchVersion): \(error.localizedDescription, privacy: .public)")
            }
        }
    }

    private func showTermsDetail(matching keyword: String) async {
        do {
            let response = try await termsService.fetchTerms()
            guard let matched = response.data.first(where: { $0.title.contains(keyword) }) else { return }
            let termItem = TermItem(
                kind: .term(id: matched.id),
                title: matched.title,
                documentUrl: matched.documentUrl,
                pdfName: TermItem.bundledPDFName(forTitle: matched.title),
                isAgreed: false
            )
            outputSubject.send(.showTermsDetail(termItem: termItem))
        } catch {
            outputSubject.send(.showErrorAlert(title: "약관을 불러오지 못했습니다."))
            logger.error("MyPage fetchTerms 실패: \(String(describing: error), privacy: .public)")
        }
    }

    private func performReset() async {
        let title = "초기화할 수 없습니다."

        do {
            let response = try await myPageService.resetPlan()
            outputSubject.send(.resetSucceeded(message: response.msg))

        } catch let error as NetworkError  {
            outputSubject.send(.showErrorAlert(title: title, description: error.errorMessage))
            logger.error("NetworkError(resetPlan): \(error.debugDescription, privacy: .public)")

        } catch {
            outputSubject.send(.showErrorAlert(title: title, description: "잠시 후 다시 시도해주세요."))
            logger.error("Unhandled error(resetPlan): \(error.localizedDescription, privacy: .public)")
        }
    }
}

extension MyPageViewModel {
    enum Input {
        case viewDidLoad
        case didTapProfile
        case didTapResetPlan
        case didConfirmResetPlan
        case didTapRegisterExam
        case didTapTermsOfService
        case didTapPrivacyPolicy
    }

    enum Output {
        case setupView(userName: String, version: String)
        case navigateToSettingsView
        case showResetAlert
        case resetSucceeded(message: String)
        case showErrorAlert(title: String, description: String? = nil)
        case showExamSchedule
        case showTermsDetail(termItem: TermItem)
    }
}
