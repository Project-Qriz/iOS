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
        
        let sendButtonTapped = rootView.findPasswordInputView.buttonTappedPublisher
            .map { FindPasswordViewModel.Input.sendButtonTapped }
        
        let nextButtonTapped = rootView.signupFooterView.buttonTappedPublisher
            .map { FindPasswordViewModel.Input.nextButtonTapped }
        
        let input = Publishers.Merge3(
            emailTextChanged,
            sendButtonTapped,
            nextButtonTapped
        )
            .eraseToAnyPublisher()
        
        let output = findPasswordVM.transform(input: input)
        
        output
            .sink { [weak self] output in
                guard let self = self else { return }
                switch output {
                case .isNameValid(let isValid):
                    self.rootView.findPasswordInputView.updateErrorState(isValid: isValid)
                    self.rootView.findPasswordInputView.updateSendButton(isValid: isValid)
                    
                case .passwordVerificationSuccess:
                    self.rootView.findPasswordInputView.handleVerificationSuccess()
                    
                case .passwordVerificationFailure:
                    print("실패")
                    
                case .navigateToPasswordResetView:
                    // MARK: - 코디네이터 적용 필요
                    print("nextView")
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
