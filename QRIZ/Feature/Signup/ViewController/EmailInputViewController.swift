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
        static let navigationTitle: String = "이메일 인증"
        static let headerTitle: String = "이메일로\n본인확인을 진행할게요!"
        static let headerDescription: String = "이메일 형식을 맞춰 입력해주세요."
        static let footerTitle: String = "다음"
        static let progressValue: Float = 0.5
        static let inputPlaceholder: String = "이메일 입력"
        static let inputErrorText: String = "이메일을 다시 확인해 주세요."
    }
    
    // MARK: - Properties
    
    private let rootView: SingleInputMainView
    private let emailInputVM: EmailInputViewModel
    private var cancellables = Set<AnyCancellable>()
    private var keyboardCancellable: AnyCancellable?
    
    // MARK: - initialize
    
    init(emailInputVM: EmailInputViewModel) {
        self.rootView = SingleInputMainView(
            title: Attributes.headerTitle,
            description: Attributes.headerDescription,
            progressValue: Attributes.progressValue,
            buttonTitle: Attributes.footerTitle,
            inputPlaceholder: Attributes.inputPlaceholder,
            inputErrorText: Attributes.inputErrorText
        )
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
        let emailTextChanged = rootView.singleInputView.textChangedPublisher
            .map { EmailInputViewModel.Input.emailTextChanged($0) }
        
        let nextButtonTapped = rootView.signupFooterView.buttonTappedPublisher
            .map { EmailInputViewModel.Input.buttonTapped }
        
        let input = Publishers.Merge(
            emailTextChanged,
            nextButtonTapped
        )
            .eraseToAnyPublisher()
        
        let output = emailInputVM.transform(input: input)
        
        output
            .sink { [weak self] output in
                guard let self = self else { return }
                switch output {
                case .isNameValid(let isValid):
                    self.rootView.singleInputView.updateErrorState(isValid: isValid)
                    self.rootView.signupFooterView.updateButtonState(isValid: isValid)
                case .navigateToVerificationCodeView:
                    // MARK: - 코디네이터 적용 필요
                    navigationController?.pushViewController(VerificationCodeViewController(), animated: true)
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
