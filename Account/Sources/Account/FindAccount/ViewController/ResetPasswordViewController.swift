//
//  ResetPasswordViewController.swift
//  QRIZ
//
//  Created by 김세훈 on 2/1/25.
//

import UIKit
import DesignSystem
import Combine
import QRIZUtils

final class ResetPasswordViewController: UIViewController {

    // MARK: - Properties

    weak var coordinator: AccountRecoveryCoordinator?
    private let rootView: ResetPasswordMainView
    private let resetPasswordVM: ResetPasswordViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(resetPasswordVM: ResetPasswordViewModel) {
        self.rootView = ResetPasswordMainView()
        self.resetPasswordVM = resetPasswordVM
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
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
        setNavigationBarTitle(title: "비밀번호 찾기", textColor: .coolNeutral800)
        bind()
        observe()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard isMovingToParent else { return }
        rootView.passwordInputView.focusInitialField()
    }

    // MARK: - Methods

    private func bind() {
        resetPasswordVM.output
            .sink { [weak self] output in
                guard let self else { return }
                switch output {
                case .characterRequirementChanged(let isValid):
                    rootView.passwordInputView.updateCharacterRequirementUI(isValid)

                case .lengthRequirementChanged(let isValid):
                    rootView.passwordInputView.updateLengthRequirementUI(isValid)

                case .passwordValidChanged(let isValid):
                    rootView.passwordInputView.updatePasswordBorderColor(isValid)

                case .confirmValidChanged(let isValid):
                    rootView.passwordInputView.updateConfirmPasswordUI(isValid)

                case .updateButtonState(let canSignUp):
                    rootView.signUpFooterView.updateButtonState(isValid: canSignUp)

                case .showErrorAlert(let errorMessage):
                    showOneButtonAlert(with: errorMessage, storingIn: &cancellables)

                case .showResetCompleteAlert:
                    showResetCompleteAlert()
                }
            }
            .store(in: &cancellables)

        rootView.passwordInputView.passwordTextChangedPublisher
            .sink { [weak self] text in self?.resetPasswordVM.send(.passwordTextChanged(text)) }
            .store(in: &cancellables)

        rootView.passwordInputView.confirmTextChangedPublisher
            .sink { [weak self] text in self?.resetPasswordVM.send(.confirmPasswordTextChanged(text)) }
            .store(in: &cancellables)

        rootView.signUpFooterView.buttonTappedPublisher
            .sink { [weak self] in self?.resetPasswordVM.send(.buttonTapped) }
            .store(in: &cancellables)
    }

    private func observe() {
        observeKeyboardNotifications(for: rootView.signUpFooterView)
            .store(in: &cancellables)

        view.tapGestureEndedPublisher()
            .sink { [weak self] _ in self?.view.endEditing(true) }
            .store(in: &cancellables)
    }

    private func showResetCompleteAlert() {
        let oneButtonAlert = OneButtonCustomAlertViewController(
            title: "비밀번호 변경 완료",
            description: "변경이 완료되었습니다.\n보안을 위해 재로그인을 진행해 주세요."
        )
        oneButtonAlert.confirmButtonTappedPublisher
            .first()
            .sink { [weak self] _ in
                oneButtonAlert.dismiss(animated: true) {
                    guard let self else { return }
                    self.coordinator?.popToRootViewController()
                }
            }
            .store(in: &cancellables)

        present(oneButtonAlert, animated: true)
    }
}
