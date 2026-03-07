//
//  IDInputViewController.swift
//  QRIZ
//
//  Created by 김세훈 on 1/3/25.
//

import UIKit
import DesignSystem
import Combine
import QRIZUtils

final class IDInputViewController: UIViewController {

    // MARK: - Properties

    weak var coordinator: SignUpCoordinator?
    private let rootView: IDInputMainView
    private let idInputVM: IDInputViewModel
    private var didFocusOnce = false
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(idInputVM: IDInputViewModel) {
        self.rootView = IDInputMainView()
        self.idInputVM = idInputVM
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
            self?.rootView.idInputView.focusInitialField()
        }
    }

    // MARK: - Methods

    private func bind() {
        idInputVM.output
            .sink { [weak self] output in
                guard let self else { return }
                switch output {
                case .isIDValid(let isValid):
                    rootView.idInputView.updateErrorState(isValid: isValid)
                    rootView.idInputView.updateDuplicateButtonState(isEnabled: isValid)

                case .duplicateCheckResult(let message, let isAvailable):
                    rootView.idInputView.updateCheckMessage(message: message, isAvailable: isAvailable)

                case .updateNextButtonState(let isEnabled):
                    rootView.signUpFooterView.updateButtonState(isValid: isEnabled)
                    rootView.idInputView.updateDuplicateButtonState(isEnabled: !isEnabled)

                case .showErrorAlert(let title):
                    showOneButtonAlert(with: title, storingIn: &cancellables)

                case .navigateToPasswordInputView:
                    coordinator?.showPasswordInput()
                }
            }
            .store(in: &cancellables)

        rootView.idInputView.textChangedPublisher
            .sink { [weak self] text in self?.idInputVM.send(.idTextChanged(text)) }
            .store(in: &cancellables)

        rootView.idInputView.buttonTappedPublisher
            .sink { [weak self] in self?.idInputVM.send(.duplicateCheckButtonTapped) }
            .store(in: &cancellables)

        rootView.signUpFooterView.buttonTappedPublisher
            .sink { [weak self] in self?.idInputVM.send(.nextButtonTapped) }
            .store(in: &cancellables)
    }

    private func observe() {
        observeKeyboardNotifications(for: rootView.signUpFooterView)
            .store(in: &cancellables)

        view.tapGestureEndedPublisher()
            .sink { [weak self] _ in self?.view.endEditing(true) }
            .store(in: &cancellables)
    }
}
