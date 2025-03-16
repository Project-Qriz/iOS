//
//  IdInputViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 1/8/25.
//

import Foundation
import Combine

final class IDInputViewModel {
    
    // MARK: - Properties
    
    private let signUpFlowViewModel: SignUpFlowViewModel
    private let authService: AuthService
    private var id: String = ""
    private let outputSubject: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialize
    
    init(
        signUpFlowViewModel: SignUpFlowViewModel,
        authService: AuthService
    ) {
        self.signUpFlowViewModel = signUpFlowViewModel
        self.authService = authService
    }
    
    // MARK: - Functions
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .idTextChanged(let newId):
                    self.validateID(newId)
                    
                case .duplicateCheckButtonTapped:
                    self.checkUsernameDuplicateAPI(self.id)
                    
                case .NextButtonTapped:
                    self.signUpFlowViewModel.updateID(id)
                    self.outputSubject.send(.navigateToPasswordInputView)
                }
            }
            .store(in: &cancellables)
        
        return outputSubject.eraseToAnyPublisher()
    }
    
    private func validateID(_ text: String) {
        let isValid = text.isValidId
        outputSubject.send(.isIDValid(isValid))
    }
    
    private func checkUsernameDuplicateAPI(_ id: String) {
        Task {
            do {
                let response = try await authService.checkUsernameDuplication(username: id)
                let available = response.data.available
                outputSubject.send(.duplicateCheckResult(message: response.msg, isAvailable: available))
                outputSubject.send(.updateNextButtonState(available))
            } catch {
                // 오류 얼랏 호출
            }
        }
    }
}

extension IDInputViewModel {
    enum Input {
        case idTextChanged(String)
        case duplicateCheckButtonTapped
        case NextButtonTapped
    }
    
    enum Output {
        case isIDValid(Bool)
        case duplicateCheckResult(message: String, isAvailable: Bool)
        case updateNextButtonState(Bool)
        case resetColor
        case navigateToPasswordInputView
    }
}

