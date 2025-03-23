//
//  IDInputViewController.swift
//  QRIZ
//
//  Created by 김세훈 on 1/3/25.
//

import UIKit
import Combine

final class IDInputViewController: UIViewController {
    
    // MARK: - Enums
    
    private enum Attributes {
        static let navigationTitle: String = "회원가입"
    }
    
    // MARK: - Properties
    
    weak var coordinator: SignUpCoordinator?
    private let rootView: IDInputMainView
    private let idInputVM: IDInputViewModel
    private var cancellables = Set<AnyCancellable>()
    private var keyboardCancellable: AnyCancellable?
    
    // MARK: - Initialize
    
    init(idInputVM: IDInputViewModel) {
        self.rootView = IDInputMainView()
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
            .map { IDInputViewModel.Input.idTextChanged($0) }
        
        let duplicateCheckButtonTapped = rootView.idInputView.buttonTappedPublisher
            .map { IDInputViewModel.Input.duplicateCheckButtonTapped }
        
        let nextButtonTapped = rootView.signUpFooterView.buttonTappedPublisher
            .map { IDInputViewModel.Input.NextButtonTapped }
        
        let input = Publishers.Merge3(
            idTextChanged,
            duplicateCheckButtonTapped,
            nextButtonTapped
        )
            .eraseToAnyPublisher()
        
        let output = idInputVM.transform(input: input)
        
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                guard let self = self else { return }
                switch output {
                case .isIDValid(let isValid):
                    self.rootView.idInputView.updateErrorState(isValid: isValid)
                    
                case .duplicateCheckResult(let message, let isAvailable):
                    self.rootView.idInputView.updateCheckMessage(message: message, isAvailable: isAvailable)
                    
                case .updateNextButtonState(let isEnabled):
                    self.rootView.signUpFooterView.updateButtonState(isValid: isEnabled)
                    
                case .resetColor:
                    self.rootView.idInputView.resetColors()
                    
                case .navigateToPasswordInputView:
                    self.coordinator?.showPasswordInput()
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
