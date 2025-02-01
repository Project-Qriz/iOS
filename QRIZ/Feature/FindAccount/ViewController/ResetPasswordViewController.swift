//
//  ResetPasswordViewController.swift
//  QRIZ
//
//  Created by 김세훈 on 2/1/25.
//

import UIKit
import Combine

final class ResetPasswordViewController: UIViewController {
    
    // MARK: - Enums
    
    private enum Attributes {
        static let navigationTitle: String = "비밀번호 찾기"
    }
    
    // MARK: - Properties
    
    private let rootView: ResetPasswordMainView
    private let resetPasswordVM: ResetPasswordViewModel
    private var cancellables = Set<AnyCancellable>()
    private var keyboardCancellable: AnyCancellable?
    
    // MARK: - initialize
    
    init(resetPasswordVM: ResetPasswordViewModel) {
        self.rootView = ResetPasswordMainView()
        self.resetPasswordVM = resetPasswordVM
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
            .map { ResetPasswordViewModel.Input.passwordTextChanged($0) }
        
        let confirmTextChanged = rootView.passwordInputView.confirmTextChangedPublisher
            .map { ResetPasswordViewModel.Input.confirmPasswordTextChanged($0) }
        
        let signupButtonTapped = rootView.signupFooterView.buttonTappedPublisher
            .map { ResetPasswordViewModel.Input.buttonTapped }
        
        let input = passwordTextChanged
            .merge(with: confirmTextChanged)
            .merge(with: signupButtonTapped)
            .eraseToAnyPublisher()
        
        let output = resetPasswordVM.transform(input: input)
        
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
                    self.showEmailSentAlert()
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
    
    private func showEmailSentAlert() {
        let confirmAction = UIAction { [weak self] _ in
            guard let self = self else { return }
            print("확인 버튼 클릭")
            self.dismiss(animated: true)
            self.navigationController?.popToRootViewController(animated: true)
        }
        
        let alertVC = CustomAlertViewController(
            alertType: .onlyConfirm,
            title: "비밀번호 변경 완료",
            description: "변경이 완료되었습니다.\n보안을 위해 재로그인을 진행해 주세요.",
            descriptionLine: 2,
            confirmAction: confirmAction
        )
        
        self.present(alertVC, animated: true)
    }
}
