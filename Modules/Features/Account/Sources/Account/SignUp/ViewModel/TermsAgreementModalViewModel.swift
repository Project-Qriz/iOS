//
//  TermsAgreementModalViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 5/15/25.
//

import Foundation
import Combine
import os
import QRIZNetwork

@MainActor
final class TermsAgreementModalViewModel {

    // MARK: - Properties

    private let signUpFlowViewModel: SignUpFlowViewModel
    private let termsService: TermsService
    private var terms: [TermItem] = []
    private let outputSubject: PassthroughSubject<Output, Never> = .init()
    private let logger = Logger.make(category: "TermsAgreementModalViewModel")

    var output: AnyPublisher<Output, Never> {
        outputSubject.eraseToAnyPublisher()
    }

    // MARK: - Initialization

    init(signUpFlowViewModel: SignUpFlowViewModel, termsService: TermsService) {
        self.signUpFlowViewModel = signUpFlowViewModel
        self.termsService = termsService
    }

    // MARK: - Methods

    func send(_ input: Input) {
        switch input {
        case .viewDidLoad:
            Task { await loadTerms() }

        case .dismissButtonTapped:
            outputSubject.send(.dismissModal)

        case .allToggle:
            let newState = !terms.allSatisfy(\.isAgreed)
            for index in terms.indices { terms[index].isAgreed = newState }
            outputSubject.send(.allAgreeChanged(newState))
            for index in terms.indices {
                outputSubject.send(.termChanged(index: index, isAgreed: newState))
            }
            sendSignUpState()

        case .termToggle(let index):
            guard terms.indices.contains(index) else { return }
            terms[index].isAgreed.toggle()
            outputSubject.send(.termChanged(index: index, isAgreed: terms[index].isAgreed))
            outputSubject.send(.allAgreeChanged(terms.allSatisfy(\.isAgreed)))
            sendSignUpState()

        case .showDetail(let index):
            outputSubject.send(.showTermsDetail(termItem: terms[index]))

        case .signUpButtonTapped:
            performJoin()
        }
    }

    private func loadTerms() async {
        do {
            let response = try await termsService.fetchTerms()
            let privacyPolicy = response.data.first { $0.title.contains("개인정보") }

            let ageConfirmation = TermItem(
                kind: .ageConfirmation,
                title: "만 14세 이상",
                documentUrl: privacyPolicy?.documentUrl,
                isAgreed: false
            )
            let serverTerms = response.data.map {
                TermItem(kind: .term(id: $0.id), title: $0.title, documentUrl: $0.documentUrl, isAgreed: false)
            }

            terms = [ageConfirmation] + serverTerms
            outputSubject.send(.initialTerms(terms))
        } catch {
            outputSubject.send(.showErrorAlert(title: "약관을 불러오지 못했습니다.", description: "잠시 후 다시 시도해 주세요."))
            logger.error("fetchTerms 실패: \(String(describing: error), privacy: .public)")
        }
    }

    private func sendSignUpState() {
        outputSubject.send(.updateSignUpButtonState(terms.allSatisfy(\.isAgreed)))
    }

    private func performJoin() {
        let over14Confirmed = terms.first { $0.kind == .ageConfirmation }?.isAgreed ?? false
        let agreedTermIds = terms.compactMap { $0.isAgreed ? $0.id : nil }

        signUpFlowViewModel.updateOver14Confirmed(over14Confirmed)
        signUpFlowViewModel.updateAgreedTermIds(agreedTermIds)

        Task {
            do {
                _ = try await signUpFlowViewModel.join()
                outputSubject.send(.signUpSucceeded)
            } catch {
                if let networkError = error as? NetworkError {
                    switch networkError {
                    case .clientError(_, _, let message, "under_age", _):
                        outputSubject.send(.showErrorAlert(title: message))
                    case .clientError(let statusCode, _, _, _, _) where statusCode == 400:
                        outputSubject.send(.showErrorAlert(title: "가입 실패", description: "처음부터 다시 진행해 주세요."))
                        logger.error("Client error 400 in performJoin: \(networkError.debugDescription, privacy: .public)")
                    default:
                        outputSubject.send(.showErrorAlert(title: networkError.errorMessage))
                    }
                } else {
                    outputSubject.send(.showErrorAlert(title: "회원가입 도중 오류가 발생했습니다."))
                    logger.error("Unhandled error in performJoin: \(String(describing: error), privacy: .public)")
                }
            }
        }
    }
}

extension TermsAgreementModalViewModel {
    enum Input {
        case viewDidLoad
        case dismissButtonTapped
        case allToggle
        case termToggle(index: Int)
        case showDetail(index: Int)
        case signUpButtonTapped
    }

    enum Output: Equatable {
        case initialTerms([TermItem])
        case dismissModal
        case allAgreeChanged(Bool)
        case termChanged(index: Int, isAgreed: Bool)
        case updateSignUpButtonState(Bool)
        case showTermsDetail(termItem: TermItem)
        case showErrorAlert(title: String, description: String? = nil)
        case signUpSucceeded
    }
}
