//
//  ChangePasswordViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 6/20/25.
//

import Foundation
import Combine
import os

final class ChangePasswordViewModel {
    
    // MARK: - Properties
    
    private let myPageService: MyPageService
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialize
    
    init(myPageService: MyPageService) {
        self.myPageService = myPageService
    }
    
    // MARK: - Functions
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .didTapForgotPassword:
                    self.outputSubject.send(.navigateToFindPassword)
                }
            }
            .store(in: &cancellables)
        
        return outputSubject.eraseToAnyPublisher()
    }
}

extension ChangePasswordViewModel {
    enum Input {
        case didTapForgotPassword
    }
    
    enum Output {
        case navigateToFindPassword
    }
}
