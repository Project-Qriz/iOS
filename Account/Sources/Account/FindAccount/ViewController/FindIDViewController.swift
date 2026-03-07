//
//  FindIDViewController.swift
//  QRIZ
//
//  Created by 김세훈 on 1/17/25.
//

import UIKit
import DesignSystem
import Combine
import QRIZUtils

final class FindIDViewController: UIViewController {

    // MARK: - Properties

    weak var coordinator: LoginCoordinator?
    private let rootView: FindIDMainView
    private let findIDInputVM: FindIDViewModel
    private var didFocusOnce = false
    private var cancellables = Set<AnyCancellable>()
    nonisolated(unsafe) private var keyboardCancellable: AnyCancellable?

    // MARK: - Initialization

    init(findIDInputVM: FindIDViewModel) {
        self.rootView = FindIDMainView()
        self.findIDInputVM = findIDInputVM
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
        setNavigationBarTitle(title: "아이디 찾기", textColor: .coolNeutral800)
        bind()
        observe()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !didFocusOnce else { return }
        didFocusOnce = true
        DispatchQueue.main.async { [weak self] in
            self?.rootView.findIDInputView.focusInitialField()
        }
    }

    deinit {
        keyboardCancellable?.cancel()
    }

    // MARK: - Methods

    private func bind() {
        findIDInputVM.output
            .sink { [weak self] output in
                guard let self else { return }
                switch output {
                case .isEmailValid(let isValid):
                    rootView.findIDInputView.updateErrorState(isValid: isValid)
                    rootView.signUpFooterView.updateButtonState(isValid: isValid)

                case .showErrorAlert(let errorMessage):
                    showOneButtonAlert(with: errorMessage, storingIn: &cancellables)

                case .showEmailSentAlert:
                    showEmailSentAlert()
                }
            }
            .store(in: &cancellables)

        rootView.findIDInputView.textChangedPublisher
            .sink { [weak self] text in self?.findIDInputVM.send(.emailTextChanged(text)) }
            .store(in: &cancellables)

        rootView.signUpFooterView.buttonTappedPublisher
            .sink { [weak self] in self?.findIDInputVM.send(.buttonTapped) }
            .store(in: &cancellables)
    }

    private func observe() {
        keyboardCancellable = observeKeyboardNotifications(for: rootView.signUpFooterView)

        view.tapGestureEndedPublisher()
            .sink { [weak self] _ in self?.view.endEditing(true) }
            .store(in: &cancellables)
    }

    private func showEmailSentAlert() {
        let oneButtonAlert = OneButtonCustomAlertViewController(
            title: "이메일 발송 완료!",
            description: "입력하신 이메일 주소로 아이디가\n발송되었습니다. 메일함을 확인해주세요."
        )
        oneButtonAlert.confirmButtonTappedPublisher
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
