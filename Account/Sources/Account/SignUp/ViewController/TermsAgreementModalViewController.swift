//
//  TermsAgreementModalViewController.swift
//  QRIZ
//
//  Created by 김세훈 on 5/13/25.
//

import UIKit
import Combine

final class TermsAgreementModalViewController: UIViewController {

    // MARK: - Properties

    weak var coordinator: SignUpCoordinator?
    private let rootView: TermsAgreementModalMainView
    private let viewModel: TermsAgreementModalViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(viewModel: TermsAgreementModalViewModel) {
        self.rootView = TermsAgreementModalMainView()
        self.viewModel = viewModel
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
        bind()
        viewModel.send(.viewDidLoad)
    }

    // MARK: - Methods

    private func bind() {
        viewModel.output
            .sink { [weak self] output in
                guard let self else { return }
                switch output {
                case .initialTerms(let terms):
                    rootView.configureItems(items: terms)

                case .dismissModal:
                    coordinator?.dismissView()

                case .allAgreeChanged(let isOn):
                    rootView.allAgreeView.setChecked(isOn)

                case .termChanged(let index, let on):
                    rootView.updateItemCheck(at: index, on: on)

                case .updateSignUpButtonState(let canSignUp):
                    rootView.footerView.updateButtonState(isValid: canSignUp)

                case .showTermsDetail(let termItem):
                    coordinator?.showTermsDetail(for: termItem)

                case .showErrorAlert(let title, let description):
                    showOneButtonAlert(with: title, for: description, storingIn: &cancellables)

                case .signUpSucceeded:
                    coordinator?.showSignUpCompleteAlert()
                }
            }
            .store(in: &cancellables)

        rootView.headerView.dismissButtonTappedPublisher
            .sink { [weak self] in self?.viewModel.send(.dismissButtonTapped) }
            .store(in: &cancellables)

        rootView.allAgreeView.checkBoxButtonTappedPublisher
            .sink { [weak self] in self?.viewModel.send(.allToggle) }
            .store(in: &cancellables)

        rootView.checkmarkTapPublisher
            .sink { [weak self] index in self?.viewModel.send(.termToggle(index: index)) }
            .store(in: &cancellables)

        rootView.detailTapPublisher
            .sink { [weak self] index in self?.viewModel.send(.showDetail(index: index)) }
            .store(in: &cancellables)

        rootView.footerView.buttonTappedPublisher
            .sink { [weak self] in self?.viewModel.send(.signUpButtonTapped) }
            .store(in: &cancellables)
    }
}
