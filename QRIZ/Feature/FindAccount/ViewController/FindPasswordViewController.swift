//
//  FindPasswordViewController.swift
//  QRIZ
//
//  Created by 김세훈 on 1/25/25.
//

import UIKit
import Combine

final class FindPasswordViewController: UIViewController {
    
    // MARK: - Enums
    
    private enum Attributes {
        static let navigationTitle: String = "비밀번호 찾기"
    }
    
    // MARK: - Properties
    
    private let rootView: FindPasswordMainView
    private let findPasswordVM: FindPasswordViewModel
    private var cancellables = Set<AnyCancellable>()
    private var keyboardCancellable: AnyCancellable?
    
    // MARK: - initialize
    
    init(findPasswordVM: FindPasswordViewModel) {
        self.rootView = FindPasswordMainView()
        self.findPasswordVM = findPasswordVM
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
    
    deinit {
        keyboardCancellable?.cancel()
    }
    
    // MARK: - Functions
    
    private func bind() {
        let emailTextChanged = rootView.findPasswordInputView.emailTextChangedPublisher
            .map { FindPasswordViewModel.Input.emailTextChanged($0) }
        
        let sendButtonTapped = rootView.findPasswordInputView.sendButtonTappedPublisher
            .map { FindPasswordViewModel.Input.sendButtonTapped }
        
        let codeTextChanged = rootView.findPasswordInputView.codeTextChangedPublisher
            .map { FindPasswordViewModel.Input.codeTextChanged($0) }
        
        let confirmButtonTapped = rootView.findPasswordInputView.confirmButtonPublisher
            .map { FindPasswordViewModel.Input.confirmButtonTapped }
        
        let nextButtonTapped = rootView.signupFooterView.buttonTappedPublisher
            .map { FindPasswordViewModel.Input.nextButtonTapped }
        
        let input = emailTextChanged
            .merge(with: sendButtonTapped)
            .merge(with: codeTextChanged)
            .merge(with: confirmButtonTapped)
            .merge(with: nextButtonTapped)
            .eraseToAnyPublisher()
        
        let output = findPasswordVM.transform(input: input)
        
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
                    self.rootView.findPasswordInputView.resetCodeTextField()
                    
                case .emailVerificationFailure:
                    print("이메일 인증 실패")
                    
                case .codeVerificationSuccess:
                    self.rootView.findPasswordInputView.handleCodeVerificationSuccess()
                    self.rootView.signupFooterView.updateButtonState(isValid: true)
                    
                case .codeVerificationFailure:
                    self.rootView.findPasswordInputView.handleCodeVerificationFailure()
                    
                case .navigateToPasswordResetView:
                    // MARK: - 코디네이터 적용 필요
                    self.navigationController?.pushViewController(ResetPasswordViewController(resetPasswordVM: ResetPasswordViewModel()), animated: true)
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
