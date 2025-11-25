//
//  TermsAgreementModalViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 5/15/25.
//

import Foundation
import Combine
import os.log

struct TermItem {
    let title: String
    let pdfName: String
    var isAgreed: Bool
}

final class TermsAgreementModalViewModel {
    
    // MARK: - Properties
    
    private let signUpFlowViewModel: SignUpFlowViewModel
    private let outputSubject: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.ksh.qriz",
                                category: "TermsAgreementModalVM")
    
    private var terms: [TermItem] = [
        .init(title: "서비스 이용약관", pdfName: "TermsOfService", isAgreed: false),
        .init(title: "개인정보 처리방침", pdfName: "PrivacyPolicy", isAgreed: false)
    ]
    
    // MARK: - Initialize
    
    init(signUpFlowViewModel: SignUpFlowViewModel) {
        self.signUpFlowViewModel = signUpFlowViewModel
    }
    
    // MARK: - Functions
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink { [weak self] event in
                guard let self = self else { return }
                
                switch event {
                case .dismissButtonTapped:
                    outputSubject.send(.dismissModal)
                    
                case .allToggle:
                    let newState = !terms.allSatisfy(\.isAgreed)
                    
                    terms = terms.map {
                        .init(title: $0.title,
                              pdfName: $0.pdfName,
                              isAgreed: newState)
                    }
                    
                    outputSubject.send(.allAgreeChanged(newState))
                    
                    for (index, _) in terms.enumerated() {
                        outputSubject.send(.termChanged(index: index, isAgreed: newState))
                    }
                    
                    sendSignUpState()
                    
                case .termToggle(let index):
                    guard terms.indices.contains(index) else { return }
                    terms[index].isAgreed.toggle()
                    outputSubject.send(.termChanged(index: index, isAgreed: terms[index].isAgreed))
                    
                    let allOn = terms.allSatisfy(\.isAgreed)
                    outputSubject.send(.allAgreeChanged(allOn))
                    sendSignUpState()
                    
                case .showDetail(let index):
                    outputSubject.send(.showTermsDetail(termItem: terms[index]))
                    
                case .signUpButtonTapped:
                    performJoin()
                }
            }
            .store(in: &cancellables)
        
        return outputSubject
            .prepend(.initialTerms(terms))
            .eraseToAnyPublisher()
    }
    
    private func sendSignUpState() {
        let canSignUp = terms.allSatisfy(\.isAgreed)
        outputSubject.send(.updateSignUpButtonState(canSignUp))
    }
    
    private func performJoin() {
        Task {
            do {
                _ = try await signUpFlowViewModel.join()
                outputSubject.send(.signUpSucceeded)
            } catch {
                if let networkError = error as? NetworkError {
                    switch networkError {
                    case .clientError(let statusCode, _, _)
                        where statusCode == 400:
                        outputSubject.send(.showErrorAlert(title: "가입 실패", description: "처음부터 다시 진행해 주세요."))
                        logger.error("Client error 400 in performJoin: \(networkError.description, privacy: .public)")
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
        case dismissButtonTapped
        case allToggle
        case termToggle(index: Int)
        case showDetail(index: Int)
        case signUpButtonTapped
    }
    
    enum Output {
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
