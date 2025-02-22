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
    
    private var id: String = ""
    private let outputSubject: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
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
                    print("id 저장")
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
    
    // username-duplicate API 호출
    private func checkUsernameDuplicateAPI(_ id: String) {
        let available = Bool.random()
        let msg = available ? "사용 가능한 아이디입니다." : "사용할 수 없는 아이디입니다. 다시 입력해 주세요."
        outputSubject.send(.duplicateCheckResult(message: msg, isAvailable: available))
        self.outputSubject.send(.updateNextButtonState(available))
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

