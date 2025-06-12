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
                    self.fetchVersion()
                    
                case .didTapTermsOfService:
                    self.outputSubject.send(.showTermsDetail(termItem: TermItem(
                        title: "서비스 이용약관",
                        pdfName: "TermsOfService",
                        isAgreed: false)))
                    
                case .didTapPrivacyPolicy:
                    self.outputSubject.send(.showTermsDetail(termItem:TermItem(
                        title: "개인정보 처리방침",
                        pdfName: "PrivacyPolicy",
                        isAgreed: false)))
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
        case didTapTermsOfService
        case didTapPrivacyPolicy
    }
    
    enum Output {
        case setupView(userName: String, version: String)
        case showTermsDetail(termItem: TermItem)
    }
}
