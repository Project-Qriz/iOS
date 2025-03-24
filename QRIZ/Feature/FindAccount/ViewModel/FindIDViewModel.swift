//
//  FindIdViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 1/17/25.
//

import Foundation
import Combine

final class FindIDViewModel {
    
    // MARK: - Properties
    
    private let accountRecoveryService: AccountRecoveryService
    private var email: String?
    private let outputSubject: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialize
    
    init(accountRecoveryService: AccountRecoveryService) {
        self.accountRecoveryService = accountRecoveryService
    }
    
    // MARK: - Functions
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .emailTextChanged(let text):
                    self.email = text
                    self.validateEmail(text)
                    
                case .buttonTapped:
                    guard let email = self.email else { return }
                    self.sendFindIDEmail(email: email)
                }
            }
            .store(in: &cancellables)
        
        return outputSubject.eraseToAnyPublisher()
    }
    
    private func validateEmail(_ text: String) {
        let isValid = text.isValidEmail
        outputSubject.send(.isNameValid(isValid))
    }
    
    private func sendFindIDEmail(email: String) {
        Task {
            do {
                _ = try await accountRecoveryService.findID(email: email)
                outputSubject.send(.navigateToAlerView)
            } catch {
                if let networkError = error as? NetworkError {
                    outputSubject.send(.showErrorAlert(networkError.errorMessage))
                } else {
                    outputSubject.send(.showErrorAlert("이메일 발송에 실패했습니다."))
                }
            }
        }
    }
}

extension FindIDViewModel {
    enum Input {
        case emailTextChanged(String)
        case buttonTapped
    }
    
    enum Output {
        case isNameValid(Bool)
        case showErrorAlert(String)
        case navigateToAlerView
    }
}
