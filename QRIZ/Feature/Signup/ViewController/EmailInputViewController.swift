//
//  EmailInputViewController.swift
//  QRIZ
//
//  Created by 김세훈 on 1/1/25.
//

import UIKit
import Combine

final class EmailInputViewController: UIViewController {
    
    // MARK: - Enums
    
    private enum Attributes {
        static let navigationTitle: String = "회원가입"
    }
    
    // MARK: - Properties
    
    private let rootView: EmailInputMainView
    private let emailInputVM: EmailInputViewModel
    private var cancellables = Set<AnyCancellable>()
    private var keyboardCancellable: AnyCancellable?
    
    // MARK: - initialize
    
    init(emailInputVM: EmailInputViewModel) {
        self.rootView = EmailInputMainView()
        self.emailInputVM = emailInputVM
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarTitle(title: Attributes.navigationTitle)
        bind()
        observe()
    }
    
    override func loadView() {
        self.view = rootView
    }
    
    // MARK: - Functions
    
    private func bind() {
        let emailTextChanged = rootView.findPasswordInputView.emailTextChangedPublisher
            .map { EmailInputViewModel.Input.emailTextChanged($0) }
        
        let sendButtonTapped = rootView.findPasswordInputView.sendButtonTappedPublisher
            .map { EmailInputViewModel.Input.sendButtonTapped }
        
        let codeTextChanged = rootView.findPasswordInputView.codeTextChangedPublisher
            .map { EmailInputViewModel.Input.codeTextChanged($0) }
        
        let confirmButtonTapped = rootView.findPasswordInputView.confirmButtonPublisher
            .map { EmailInputViewModel.Input.confirmButtonTapped }
        
        let nextButtonTapped = rootView.signupFooterView.buttonTappedPublisher
            .map { EmailInputViewModel.Input.nextButtonTapped }
        
        let input = emailTextChanged
            .merge(with: sendButtonTapped)
            .merge(with: codeTextChanged)
            .merge(with: confirmButtonTapped)
            .merge(with: nextButtonTapped)
            .eraseToAnyPublisher()
        
        let output = emailInputVM.transform(input: input)
        
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                guard let self = self else { return }
                switch output {
                case .isEmailValid(let isValid):
                    self.rootView.findPasswordInputView.updateErrorState(for: .email, isValid: isValid)
                    self.rootView.findPasswordInputView.updateSendButton(isValid: isValid)
                    
                case .isCodeValid(let isValid):
                    self.rootView.findPasswordInputView.updateConfirmButton(isValid: isValid)
                    
                case .emailVerificationSuccess:
                    self.rootView.findPasswordInputView.handleEmailVerificationSuccess()
                    
                case .updateRemainingTime(let remainingTime):
                    self.rootView.findPasswordInputView.updateTimerLabel(remainingTime)
                    
                case .timerExpired:
                    self.rootView.findPasswordInputView.handleTimerExpired()
                    
                case .emailVerificationFailure:
                    print("이메일 인증 실패")
                    
                case .codeVerificationSuccess:
                    self.rootView.findPasswordInputView.handleCodeVerificationSuccess()
                    self.rootView.signupFooterView.updateButtonState(isValid: true)
                    
                case .codeVerificationFailure:
                    self.rootView.findPasswordInputView.handleCodeVerificationFailure()
                    
                case .navigateToPasswordResetView:
                    // MARK: - 코디네이터 적용 필요
                    self.navigationController?.pushViewController(NameInputViewController(nameInputVM: NameInputViewModel()), animated: true)
                }
            }
            .store(in: &cancellables)
    }
    
    private func observe() {
        keyboardCancellable = observeKeyboardNotifications(for: rootView.signupFooterView)
        
        view.tapGestureEndedPublisher()
            .sink { [weak self] _ in
                self?.view.endEditing(true)
            }
            .store(in: &cancellables)
    }
}
