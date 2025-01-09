//
//  IdInputViewController.swift
//  QRIZ
//
//  Created by 김세훈 on 1/3/25.
//

import UIKit
import Combine

final class IdInputViewController: UIViewController {
    
    // MARK: - Enums
    
    private enum Attributes {
        static let navigationTitle: String = "회원가입"
    }
    
    // MARK: - Properties
    
    private let rootView: IdInputMainView
    private let idInputVM: IdInputViewModel
    private var cancellables = Set<AnyCancellable>()
    private var keyboardCancellable: AnyCancellable?
    
    // MARK: - initialize
    
    init(idInputVM: IdInputViewModel) {
        self.rootView = IdInputMainView()
        self.idInputVM = idInputVM
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
        let idTextChanged = rootView.idInputView.textChangedPublisher
            .map { IdInputViewModel.Input.idTextChanged($0) }
        
        let duplicateCheckButtonTapped = rootView.idInputView.buttonTappedPublisher
            .map { IdInputViewModel.Input.duplicateCheckButtonTapped }
        
        let nextButtonTapped = rootView.signupFooterView.buttonTappedPublisher
            .map { IdInputViewModel.Input.NextButtonTapped }
        
        let input = Publishers.Merge3(
            idTextChanged,
            duplicateCheckButtonTapped,
            nextButtonTapped
        )
            .eraseToAnyPublisher()
        
        let output = idInputVM.transform(input: input)
        
        output
            .sink { [weak self] output in
                guard let self = self else { return }
                switch output {
                case .textCount(let current, let min):
                    self.rootView.idInputView.updateTextCountLabel(current: current, min: min)
                    
                case .duplicateCheckResult(let message, let isAvailable):
                    self.rootView.idInputView.updateCheckMessage(message: message, isAvailable: isAvailable)
                    
                case .updateNextButtonState(let isEnabled):
                    self.rootView.signupFooterView.updateButtonState(isValid: isEnabled)
                    
                case .resetColor:
                    self.rootView.idInputView.resetColors()
                    
                case .navigateToPasswordInputView:
                    // MARK: - 코디네이터 적용 필요
                    navigationController?.pushViewController(PasswordInputViewController(), animated: true)
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
