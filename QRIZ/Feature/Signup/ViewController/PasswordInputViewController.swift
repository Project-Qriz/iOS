//
//  PasswordInputViewController.swift
//  QRIZ
//
//  Created by 김세훈 on 1/4/25.
//

import UIKit
import Combine

final class PasswordInputViewController: UIViewController {
    
    // MARK: - Enums
    
    private enum Attributes {
        static let navigationTitle: String = "회원가입"
        static let alertTitle: String = "회원가입 완료!"
        static let alertDescription: String = "회원가입이 완료되었습니다.\n합격을 향한 여정을 함께 시작해봐요!"
    }
    
    // MARK: - Properties
    
    private let rootView: PasswordInputMainView
    private let passwordInputVM: PasswordInputViewModel
    private var cancellables = Set<AnyCancellable>()
    private var keyboardCancellable: AnyCancellable?
    
    
    // MARK: - initialize
    
    init(passwordInputVM: PasswordInputViewModel) {
        self.rootView = PasswordInputMainView()
        self.passwordInputVM = passwordInputVM
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
        let passwordTextChanged = rootView.passwordInputView.passwordTextChangedPublisher
            .map { PasswordInputViewModel.Input.passwordTextChanged($0) }
        
        let confirmTextChanged = rootView.passwordInputView.confirmTextChangedPublisher
            .map { PasswordInputViewModel.Input.confirmPasswordTextChanged($0) }
        
        let signupButtonTapped = rootView.signupFooterView.buttonTappedPublisher
            .map { PasswordInputViewModel.Input.buttonTapped }
        
        let input = passwordTextChanged
            .merge(with: confirmTextChanged)
            .merge(with: signupButtonTapped)
            .eraseToAnyPublisher()
        
        let output = passwordInputVM.transform(input: input)
        
        output
            .sink { [weak self] output in
                guard let self = self else { return }
                
                switch output {
                case .characterRequirementChanged(let isValid):
                    self.rootView.passwordInputView.updateCharacterRequirementUI(isValid)
                    
                case .lengthRequirementChanged(let isValid):
                    self.rootView.passwordInputView.updateLengthRequirementUI(isValid)
                    
                case .confirmValidChanged(let isValid):
                    self.rootView.passwordInputView.updateConfirmPasswordUI(isValid)
                    
                case .updateSignupButtonState(let canSignUp):
                    self.rootView.signupFooterView.updateButtonState(isValid: canSignUp)
                    
                case .navigateToAlertView:
                    self.showOneButtonAlert()
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
        let oneButtonAlert = OneButtonCustomAlertViewController(
            title: Attributes.alertTitle,
            description: Attributes.alertDescription
        )
        oneButtonAlert.confirmButtonTappedPublisher
            .sink { [weak self] _ in
                oneButtonAlert.dismiss(animated: true) {
                    guard let self = self else { return }
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
            .store(in: &cancellables)
        
        present(oneButtonAlert, animated: true)
    }
}
