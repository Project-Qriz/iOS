//
//  MyPageViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 6/9/25.
//

import Foundation
import Combine

final class MyPageViewModel {
    
    // MARK: - Properties
    
    private let userName: String
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialize
    
    init(userName: String) {
        self.userName = userName
    }
    
    // MARK: - Functions
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .viewDidLoad:
                    fetchVersion()
                }
            }
            .store(in: &cancellables)
        
        return outputSubject.eraseToAnyPublisher()
    }
    
    // 백엔드 수정중
    private func fetchVersion() {
        outputSubject.send(.setupView(userName: userName, version: "2.1.2"))
    }
}

extension MyPageViewModel {
    enum Input {
        case viewDidLoad
    }
    
    enum Output {
        case setupView(userName: String, version: String)
    }
}
