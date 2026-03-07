//
//  SignUpVerificationViewController.swift
//  QRIZ
//
//  Created by 김세훈 on 1/1/25.
//

import UIKit
import DesignSystem
import Combine
import QRIZUtils

final class SignUpVerificationViewController: UIViewController {

    // MARK: - Properties

    weak var coordinator: SignUpCoordinator?
    private let rootView: SignUpVerificationMainView
    private let signUpVerificationVM: SignUpVerificationViewModel
    private var didFocusOnce = false
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(signUpVerificationVM: SignUpVerificationViewModel) {
        self.rootView = SignUpVerificationMainView()
        self.signUpVerificationVM = signUpVerificationVM
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
        rootView.verificationInputView.focusInitialField()
    }

    // MARK: - Methods

    private func bind() {
        signUpVerificationVM.output
            .sink { [weak self] output in
                guard let self else { return }
                switch output {
                case .isEmailValid(let isValid):
                    rootView.verificationInputView.updateErrorState(for: .email, isValid: isValid)
                    rootView.verificationInputView.updateSendButton(isValid: isValid)

                case .isCodeValid(let isValid):
                    rootView.verificationInputView.updateConfirmButton(isValid: isValid)

                case .emailVerificationInProgress:
                    rootView.verificationInputView.showMessage("이메일 확인중...", textColor: .coolNeutral500)

                case .emailVerificationSuccess:
                    rootView.verificationInputView.handleEmailVerificationSuccess()

                case .emailVerificationDuplicate(let errorMessage):
                    rootView.verificationInputView.updateErrorState(for: .email, isValid: false, message: errorMessage)

                case .showErrorAlert(let title):
                    showOneButtonAlert(with: title, storingIn: &cancellables)

                case .updateRemainingTime(let remainingTime):
                    rootView.verificationInputView.updateTimerLabel(remainingTime)

                case .timerExpired:
                    rootView.verificationInputView.handleTimerExpired()

                case .codeVerificationSuccess:
                    rootView.verificationInputView.handleCodeVerificationSuccess()
                    rootView.signUpFooterView.updateButtonState(isValid: true)

                case .codeVerificationFailure:
                    rootView.verificationInputView.handleCodeVerificationFailure()

                case .navigateToNextView:
                    coordinator?.showNameInput()
                }
            }
            .store(in: &cancellables)

        rootView.verificationInputView.emailTextChangedPublisher
            .sink { [weak self] text in self?.signUpVerificationVM.send(.emailTextChanged(text)) }
            .store(in: &cancellables)

        rootView.verificationInputView.sendButtonTappedPublisher
            .sink { [weak self] in self?.signUpVerificationVM.send(.sendButtonTapped) }
            .store(in: &cancellables)

        rootView.verificationInputView.codeTextChangedPublisher
            .sink { [weak self] text in self?.signUpVerificationVM.send(.codeTextChanged(text)) }
            .store(in: &cancellables)

        rootView.verificationInputView.confirmButtonPublisher
            .sink { [weak self] in self?.signUpVerificationVM.send(.confirmButtonTapped) }
            .store(in: &cancellables)

        rootView.signUpFooterView.buttonTappedPublisher
            .sink { [weak self] in self?.signUpVerificationVM.send(.nextButtonTapped) }
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
