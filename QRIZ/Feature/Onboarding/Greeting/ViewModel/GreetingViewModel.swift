//
//  GreetingViewModel.swift
//  QRIZ
//
//  Created by ch on 12/20/24.
//

import Foundation
import Combine

final class GreetingViewModel {
    
    // MARK: - Input & Output
    enum Input {
        case viewDidLoad
        case viewDidAppear
    }
    
    enum Output {
        case moveToHome
        case fetchFailed
    }
    
    // MARK: - Properties
    private let output: PassthroughSubject<Output, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    private var timer: Timer?
    
    private let userInfoService: UserInfoService
    
    // MARK: - Initializer
    init(userInfoService: UserInfoService) {
        self.userInfoService = userInfoService
    }
    
    // MARK: - Methods
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .viewDidLoad:
                self.updateUserInfo()
            case .viewDidAppear:
                self.startTimer()
            }
        }
        .store(in: &subscriptions)
        
        return output.eraseToAnyPublisher()
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.output.send(.moveToHome)
            timer?.invalidate()
        }
    }
    
    private func updateUserInfo() {
        Task {
            do {
                let response = try await userInfoService.getUserInfo()
                UserInfoManager.shared.update(from: response.data)
            } catch {
                output.send(.fetchFailed)
            }
        }
    }
}
