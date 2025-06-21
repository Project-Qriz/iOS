//
//  ChangePasswordViewController.swift
//  QRIZ
//
//  Created by 김세훈 on 6/20/25.
//

import UIKit
import Combine

final class ChangePasswordViewController: UIViewController {
    
    // MARK: - Enums
    
    private enum Attributes {
        static let navigationTitle: String = "비밀번호 재설정"
    }
    
    // MARK: - Properties
    
    weak var coordinator: MyPageCoordinator?
    private let rootView: ChangePasswordMainView
    private let viewModel: ChangePasswordViewModel
    private let inputSubject = PassthroughSubject<ChangePasswordViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var keyboardCancellable: AnyCancellable?
    
    // MARK: - Initialize
    
    init(viewModel: ChangePasswordViewModel) {
        self.rootView = ChangePasswordMainView()
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    
    override func loadView() {
        self.view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        observe()
        setNavigationBarTitle(title: Attributes.navigationTitle)
    }
    
    deinit {
        keyboardCancellable?.cancel()
    }
    
    // MARK: - Functions
    
    private func bind() {
        
        let currentPwdChanged = rootView.changePasswordInputView.newPasswordChangedPublisher
            .map { ChangePasswordViewModel.Input.currentPasswordChanged($0) }
        
        let newPwdChanged = rootView.changePasswordInputView
            .currentPasswordChangedPublisher
            .map { ChangePasswordViewModel.Input.newPasswordChanged($0) }
        
        let forgotPasswordTap = rootView.forgotPasswordTappedPublisher
            .map { ChangePasswordViewModel.Input.didTapForgotPassword }
        
        let input = currentPwdChanged
            .merge(with: newPwdChanged)
            .merge(with: forgotPasswordTap)
            .eraseToAnyPublisher()
        
        let output = viewModel.transform(input: input)
        
        output
            .sink { [weak self] output in
                guard let self = self else { return }
                switch output {
                case .updateChangeButtonState(let enabled):
                    self.rootView.signUpFooterView.updateButtonState(isValid: enabled)
                    
                case .navigateToFindPassword:
                    self.coordinator?.showFindPassword()
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
