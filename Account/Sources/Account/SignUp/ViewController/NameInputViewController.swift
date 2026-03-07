//
//  NameInputViewController.swift
//  QRIZ
//
//  Created by 김세훈 on 12/31/24.
//

import UIKit
import DesignSystem
import Combine

final class NameInputViewController: UIViewController {

    // MARK: - Properties

    weak var coordinator: SignUpCoordinator?
    private let rootView: NameInputMainView
    private let nameInputVM: NameInputViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(nameInputVM: NameInputViewModel) {
        self.rootView = NameInputMainView()
        self.nameInputVM = nameInputVM
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
        guard isMovingToParent else { return }
        rootView.singleInputView.focusInitialField()
    }

    // MARK: - Methods

    private func bind() {
        nameInputVM.output
            .sink { [weak self] output in
                guard let self else { return }
                switch output {
                case .isNameValid(let isValid):
                    rootView.singleInputView.updateErrorState(isValid: isValid)
                    rootView.signUpFooterView.updateButtonState(isValid: isValid)

                case .navigateToEmailInputView:
                    coordinator?.showIDInput()
                }
            }
            .store(in: &cancellables)

        rootView.singleInputView.textChangedPublisher
            .sink { [weak self] text in self?.nameInputVM.send(.nameTextChanged(text)) }
            .store(in: &cancellables)

        rootView.signUpFooterView.buttonTappedPublisher
            .sink { [weak self] in self?.nameInputVM.send(.buttonTapped) }
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
