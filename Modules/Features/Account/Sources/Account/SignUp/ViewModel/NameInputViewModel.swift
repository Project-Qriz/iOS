//
//  NameInputViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 1/7/25.
//

import Foundation
import Combine

@MainActor
final class NameInputViewModel {

    // MARK: - Properties

    private let signUpFlowViewModel: SignUpFlowViewModel
    private var name: String = ""
    private let outputSubject: PassthroughSubject<Output, Never> = .init()

    var output: AnyPublisher<Output, Never> {
        outputSubject.eraseToAnyPublisher()
    }

    // MARK: - Initialization

    init(signUpFlowViewModel: SignUpFlowViewModel) {
        self.signUpFlowViewModel = signUpFlowViewModel
    }

    // MARK: - Methods

    func send(_ input: Input) {
        switch input {
        case .nameTextChanged(let text):
            validateName(text)

        case .buttonTapped:
            signUpFlowViewModel.updateName(name)
            outputSubject.send(.navigateToIDInputView)
        }
    }

    private func validateName(_ text: String) {
        let isValid = text.isValidName
        name = text
        outputSubject.send(.isNameValid(isValid))
    }
}

extension NameInputViewModel {
    enum Input {
        case nameTextChanged(String)
        case buttonTapped
    }

    enum Output: Equatable {
        case isNameValid(Bool)
        case navigateToIDInputView
    }
}
