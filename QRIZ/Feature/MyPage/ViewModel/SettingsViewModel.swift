//
//  SettingsViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 6/15/25.
//

import Foundation
import Combine

final class SettingsViewModel {
    
    // MARK: - Properties
    
    private let userName: String
    private let email: String
    private let myPageService: MyPageService
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialize
    
    init(
        userName: String,
        email: String,
        myPageService: MyPageService
    ) {
        self.userName = userName
        self.email = email
        self.myPageService = myPageService
    }
    
    // MARK: - Functions
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                }
            }
            .store(in: &cancellables)
        
        return outputSubject.eraseToAnyPublisher()
    }
}

extension SettingsViewModel {
    enum Input {
    }
    
    enum Output {
    }
}
