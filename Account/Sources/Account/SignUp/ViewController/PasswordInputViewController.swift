//
//  PasswordInputViewController.swift
//  QRIZ
//
//  Created by 김세훈 on 1/4/25.
//

import UIKit
import DesignSystem
import Combine

final class PasswordInputViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var coordinator: SignUpCoordinator?
    private let rootView: PasswordInputMainView
    private let passwordInputVM: PasswordInputViewModel
    private var didFocusOnce = false
    private var cancellables = Set<AnyCancellable>()
    nonisolated(unsafe) private var keyboardCancellable: AnyCancellable?
    
    // MARK: - Initialization
    
    init(passwordInputVM: PasswordInputViewModel) {
        self.rootView = PasswordInputMainView()
        self.passwordInputVM = passwordInputVM
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle

    override func loadView() {
        self.view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarTitle(title: "회원가입", textColor: .coolNeutral800)
        bind()
        observe()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard !didFocusOnce else { return }
        didFocusOnce = true

        DispatchQueue.main.async { [weak self] in
            self?.rootView.passwordInputView.focusInitialField()
        }
    }
    
    deinit {
        keyboardCancellable?.cancel()
    }
    
    // MARK: - Methods
    
    private func bind() {
        let passwordTextChanged = rootView.passwordInputView.passwordTextChangedPublisher
            .map { PasswordInputViewModel.Input.passwordTextChanged($0) }
        
        let confirmTextChanged = rootView.passwordInputView.confirmTextChangedPublisher
            .map { PasswordInputViewModel.Input.confirmPasswordTextChanged($0) }
        
        let signUpButtonTapped = rootView.signUpFooterView.buttonTappedPublisher
            .map { PasswordInputViewModel.Input.buttonTapped }
        
        let input = passwordTextChanged
            .merge(with: confirmTextChanged)
            .merge(with: signUpButtonTapped)
            .eraseToAnyPublisher()
        
        let output = passwordInputVM.transform(input: input)
        
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                guard let self else { return }
                
                switch output {
                case .characterRequirementChanged(let isValid):
                    self.rootView.passwordInputView.updateCharacterRequirementUI(isValid)
                    
                case .lengthRequirementChanged(let isValid):
                    self.rootView.passwordInputView.updateLengthRequirementUI(isValid)
                    
                case .confirmValidChanged(let isValid):
                    self.rootView.passwordInputView.updateConfirmPasswordUI(isValid)
                    
                case .updateButtonState(let canSignUp):
                    self.rootView.signUpFooterView.updateButtonState(isValid: canSignUp)

                case .showTermsAgreementModal:
                    self.coordinator?.showTermsAgreementModal()
                }
            }
            .store(in: &cancellables)
    }
    
    private func observe() {
        keyboardCancellable = observeKeyboardNotifications(for: rootView.signUpFooterView)
        
        view.tapGestureEndedPublisher()
            .sink { [weak self] _ in
                self?.view.endEditing(true)
            }
            .store(in: &cancellables)
    }
}
