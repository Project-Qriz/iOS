//
//  VerificationCodeViewController.swift
//  QRIZ
//
//  Created by 김세훈 on 1/1/25.
//

import UIKit
import Combine

final class VerificationCodeViewController: UIViewController {
    
    // MARK: - Enums
    
    private enum Attributes {
        static let navigationTitle: String = "이메일 인증"
    }
    
    // MARK: - Properties
    
    private let rootView: VerificationCodeMainView
    private let verificationCodeVM: VerificationCodeViewModel
    private let viewLifecycleSubject = PassthroughSubject<VerificationCodeViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var keyboardCancellable: AnyCancellable?
    
    // MARK: - Initialize
    
    init(verificationCodeVM: VerificationCodeViewModel) {
        self.rootView = VerificationCodeMainView()
        self.verificationCodeVM = verificationCodeVM
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
        viewLifecycleSubject.send(.viewDidLoad)
    }
    
    override func loadView() {
        self.view = rootView
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewLifecycleSubject.send(.viewWillDisappear)
    }
    
    deinit {
        keyboardCancellable?.cancel()
    }
    
    // MARK: - Functions
    
    private func bind() {
        let codeTextChanged = rootView.verificationCodeInputView.textChangedPublisher
            .map { VerificationCodeViewModel.Input.codeTextChanged($0) }
        
        let resendCodeTapped = rootView.verificationCodeInputView.resendCodePublisher
            .map { VerificationCodeViewModel.Input.resendCodeTapped }
        
        let nextButtonTapped = rootView.signupFooterView.buttonTappedPublisher
            .map { VerificationCodeViewModel.Input.buttonTapped }
        
        let input = Publishers.Merge3(
            codeTextChanged,
            resendCodeTapped,
            nextButtonTapped
        )
            .merge(with: viewLifecycleSubject)
            .eraseToAnyPublisher()
        
        let output = verificationCodeVM.transform(input: input)
        
        output
            .sink { [weak self] output in
                guard let self = self else { return }
                switch output {
                case .isCodeValid(let isValid):
                    self.rootView.signupFooterView.updateButtonState(isValid: isValid)
                    
                case .verificationFailed:
                    self.rootView.verificationCodeInputView.updateErrorState(false)
                    
                case .updateRemainingTime(let remainingTime):
                    self.rootView.verificationCodeInputView.updateTimerLabel(remainingTime)
                    
                case .navigateToIdInputView:
                    // MARK: - 코디네이터 적용 필요
                    navigationController?.pushViewController(IdInputViewController(idInputVM: IdInputViewModel()), animated: true)
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
