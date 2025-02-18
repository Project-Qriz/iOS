//
//  SignUpVerificationViewController.swift
//  QRIZ
//
//  Created by 김세훈 on 1/1/25.
//

import UIKit
import Combine

final class SignUpVerificationViewController: UIViewController {
    
    // MARK: - Enums
    
    private enum Attributes {
        static let navigationTitle: String = "회원가입"
        static let alertTitle: String = "이메일을 올바르게 입력해주세요."
    }
    
    // MARK: - Properties
    
    private let rootView: SignUpVerificationMainView
    private let signUpVerificationVM: SignUpVerificationViewModel
    private var cancellables = Set<AnyCancellable>()
    private var keyboardCancellable: AnyCancellable?
    
    // MARK: - initialize
    
    init(signUpVerificationVM: SignUpVerificationViewModel) {
        self.rootView = SignUpVerificationMainView()
        self.signUpVerificationVM = signUpVerificationVM
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
        let emailTextChanged = rootView.verificationInputView.emailTextChangedPublisher
            .map { SignUpVerificationViewModel.Input.emailTextChanged($0) }
        
        let sendButtonTapped = rootView.verificationInputView.sendButtonTappedPublisher
            .map { SignUpVerificationViewModel.Input.sendButtonTapped }
        
        let codeTextChanged = rootView.verificationInputView.codeTextChangedPublisher
            .map { SignUpVerificationViewModel.Input.codeTextChanged($0) }
        
        let confirmButtonTapped = rootView.verificationInputView.confirmButtonPublisher
            .map { SignUpVerificationViewModel.Input.confirmButtonTapped }
        
        let nextButtonTapped = rootView.signupFooterView.buttonTappedPublisher
            .map { SignUpVerificationViewModel.Input.nextButtonTapped }
        
        let input = emailTextChanged
            .merge(with: sendButtonTapped)
            .merge(with: codeTextChanged)
            .merge(with: confirmButtonTapped)
            .merge(with: nextButtonTapped)
            .eraseToAnyPublisher()
        
        let output = signUpVerificationVM.transform(input: input)
        
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                guard let self = self else { return }
                switch output {
                case .isEmailValid(let isValid):
                    self.rootView.verificationInputView.updateErrorState(for: .email, isValid: isValid)
                    self.rootView.verificationInputView.updateSendButton(isValid: isValid)
                    
                case .isCodeValid(let isValid):
                    self.rootView.verificationInputView.updateConfirmButton(isValid: isValid)
                    
                case .emailVerificationSuccess:
                    self.rootView.verificationInputView.handleEmailVerificationSuccess()
                    
                case .updateRemainingTime(let remainingTime):
                    self.rootView.verificationInputView.updateTimerLabel(remainingTime)
                    
                case .timerExpired:
                    self.rootView.verificationInputView.handleTimerExpired()
                    
                case .emailVerificationFailure:
                    self.showOneButtonAlert()
                    
                case .codeVerificationSuccess:
                    self.rootView.verificationInputView.handleCodeVerificationSuccess()
                    self.rootView.signupFooterView.updateButtonState(isValid: true)
                    
                case .codeVerificationFailure:
                    self.rootView.verificationInputView.handleCodeVerificationFailure()
                    
                case .navigateToNextView:
                    // MARK: - 코디네이터 적용 필요
                    self.navigationController?.pushViewController(
                        NameInputViewController(nameInputVM: NameInputViewModel()),
                        animated: true
                    )
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
    
    private func showOneButtonAlert() {
        let oneButtonAlert = OneButtonCustomAlertViewController(title: Attributes.alertTitle)
        oneButtonAlert.confirmButtonTappedPublisher
            .sink { oneButtonAlert.dismiss(animated: true) }
            .store(in: &cancellables)
        
        present(oneButtonAlert, animated: true)
    }
}
