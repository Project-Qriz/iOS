//
//  IdInputViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 1/8/25.
//

import Foundation
import Combine
import os

final class IDInputViewModel {
    
    // MARK: - Properties
    
    private let signUpFlowViewModel: SignUpFlowViewModel
    private let signUpService: SignUpService
    private var id: String = ""
    private let outputSubject: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "kr.QRIZ", category: "IDInputViewModel")
    
    // MARK: - Initialize
    
    init(
        signUpFlowViewModel: SignUpFlowViewModel,
        signUpService: SignUpService
    ) {
        self.signUpFlowViewModel = signUpFlowViewModel
        self.signUpService = signUpService
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
                let response = try await signUpService.checkUsernameDuplication(username: id)
                let available = response.data.available
                outputSubject.send(.duplicateCheckResult(message: response.msg, isAvailable: available))
                outputSubject.send(.updateNextButtonState(available))
            } catch {
                if let networkError = error as? NetworkError {
                    switch networkError {
                    case .clientError(_, let serverCode, let message):
                        if serverCode == -1 {
                            outputSubject.send(.duplicateCheckResult(message: message, isAvailable: false))
                            outputSubject.send(.updateNextButtonState(false))
                        } else {
                            outputSubject.send(.showErrorAlert(title: networkError.errorMessage))
                            logger.error("Client error in checkUsernameDuplicateAPI: \(networkError.description, privacy: .public)")
                        }
                    default:
                        outputSubject.send(.showErrorAlert(title: networkError.errorMessage))
                        
                    }
                } else {
                    outputSubject.send(.showErrorAlert(title: "아이디 중복 확인에 실패했습니다."))
                    logger.error("Unhandled error in checkUsernameDuplicateAPI: \(String(describing: error), privacy: .public)")
                }
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
        case showErrorAlert(title: String)
        case resetColor
        case navigateToPasswordInputView
    }
}

