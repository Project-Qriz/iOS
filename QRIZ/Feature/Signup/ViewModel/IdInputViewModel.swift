//
//  IdInputViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 1/8/25.
//

import Foundation
import Combine

final class IdInputViewModel {
    
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
                    self.handleIdChange(newId)
                    
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
    
    private func handleIdChange(_ newId: String) {
        if id != newId {
            
            outputSubject.send(.updateNextButtonState(false))
        }
        
        id = newId
        outputSubject.send(.textCount(current: newId.count, min: 8))
    }
    
    // username-duplicate API 호출
    private func checkUsernameDuplicateAPI(_ id: String) {
        let available = Bool.random()
        let msg = available ? "사용 가능한 아이디입니다." : "사용 불가능한 아이디입니다."
        outputSubject.send(.duplicateCheckResult(message: msg, isAvailable: available))
        self.outputSubject.send(.updateNextButtonState(available))
    }
}

extension IdInputViewModel {
    enum Input {
        case idTextChanged(String)
        case duplicateCheckButtonTapped
        case NextButtonTapped
    }
    
    enum Output {
        case textCount(current: Int, min: Int)
        case duplicateCheckResult(message: String, isAvailable: Bool)
        case updateNextButtonState(Bool)
        case resetColor
        case navigateToPasswordInputView
    }
}

