//
//  TermsAgreementModalViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 5/15/25.
//

import Foundation
import Combine

struct TermItem {
    let title: String
    var isAgreed: Bool
}

final class TermsAgreementModalViewModel {
    
    // MARK: - Properties
    
    private let outputSubject: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    private var terms: [TermItem] = [
        .init(title: "서비스 이용약관 동의", isAgreed: false),
        .init(title: "개인정보 처리방침 동의", isAgreed: false)
    ]
    
    // MARK: - Functions
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink { [weak self] event in
                guard let self = self else { return }
                
                switch event {
                case .viewDidLoad:
                    outputSubject.send(.initialTerms(terms))
                    
                case .dismissButtonTapped:
                    outputSubject.send(.dismissModal)
                    
                case .allToggle(let on):
                    terms = terms.map { .init(title: $0.title, isAgreed: on) }
                    outputSubject.send(.allAgreeChanged(on))
                    
                    terms.enumerated().forEach { index, term in
                        self.outputSubject.send(.termChanged(index: index, isAgreed: term.isAgreed))
                    }
                    
                    sendSignUpState()
                    
                case .termToggle(let index):
                    guard terms.indices.contains(index) else { return }
                    terms[index].isAgreed.toggle()
                    outputSubject.send(.termChanged(index: index, isAgreed: terms[index].isAgreed))
                    
                    let allOn = terms.allSatisfy(\.isAgreed)
                    outputSubject.send(.allAgreeChanged(allOn))
                    sendSignUpState()
                    
                case .showDetail(let index):
                    outputSubject.send(.showTermsDetail(index: index))
                }
            }
            .store(in: &cancellables)
        
        return outputSubject
            .prepend(.initialTerms(terms))
            .eraseToAnyPublisher()
    }
    
    private func sendSignUpState() {
        let canSignUp = terms.allSatisfy(\.isAgreed)
        outputSubject.send(.updateSignUpButtonState(canSignUp))
    }
}

extension TermsAgreementModalViewModel {
    enum Input {
        case viewDidLoad
        case dismissButtonTapped
        case allToggle(Bool)
        case termToggle(index: Int)
        case showDetail(index: Int)
    }
    
    enum Output {
        case initialTerms([TermItem])
        case dismissModal
        case allAgreeChanged(Bool)
        case termChanged(index: Int, isAgreed: Bool)
        case updateSignUpButtonState(Bool)
        case showTermsDetail(index: Int)
    }
}
