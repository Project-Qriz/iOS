//
//  DailyTestViewController.swift
//  QRIZ
//
//  Created by 이창현 on 4/1/25.
//

import UIKit
import DesignSystem
import Combine
import QRIZUtils

final class DailyTestViewController: UIViewController {

    // MARK: - Properties

    private var contentView: DailyTestView!
    private let viewModel: DailyTestViewModel
    private let input: PassthroughSubject<DailyTestViewModel.Input, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()

    private let submitAlertViewController = TwoButtonCustomAlertViewController(
        title: "제출하시겠습니까?",
        description: "확인 버튼을 누르면 다시 돌아올 수 없어요."
    )

    weak var coordinator: (any DailyNavigating)?

    // MARK: - Initializers

    init(viewModel: DailyTestViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: DailyTestViewController")
    }

    // MARK: - Lifecycle

    override func loadView() {
        contentView = DailyTestView()
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationItems()
        setAlertButtonActions()
        bind()
        input.send(.viewDidLoad)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        input.send(.viewDidAppear)
    }

    // MARK: - Bind

    private func bind() {
        let merged = input.merge(with: contentView.userInputPublisher)
        viewModel.transform(input: merged.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self else { return }
                handleOutput(event)
            }
            .store(in: &subscriptions)
    }
}

// MARK: - Output Handling

extension DailyTestViewController {
    private func handleOutput(_ event: DailyTestViewModel.Output) {
        switch event {
        case .fetchFailed(let isServerError):
            if isServerError {
                showOneButtonAlert(with: "Server Error", for: "관리자에게 문의하세요.", storingIn: &subscriptions)
            } else {
                showOneButtonAlert(with: "잠시 후 다시 시도해주세요.", storingIn: &subscriptions)
            }
        case .updateQuestion(let question):
            contentView.updateQuestion(question)
        case .updateTotalPage(let totalPage):
            contentView.updateTotalPage(totalPage)
        case .updateTime(let timeLimit, let timeRemaining):
            contentView.updateProgress(timeLimit: timeLimit, timeRemaining: timeRemaining)
        case .updateOptionState(let optionIdx, let isSelected):
            contentView.updateOptionState(at: optionIdx, isSelected: isSelected)
        case .setButtonVisibility(let isVisible):
            contentView.setButtonsVisibility(isVisible: isVisible)
        case .alterButtonText:
            contentView.alterButtonText()
        case .moveToDailyResult:
            coordinator?.showDailyResult()
        case .moveToHomeView:
            coordinator?.quitDaily()
        case .popSubmitAlert:
            present(submitAlertViewController, animated: true)
        case .cancelAlert:
            submitAlertViewController.dismiss(animated: true)
        case .submitSuccess:
            submitAlertViewController.dismiss(animated: true)
            removeNavigationItems()
        case .submitFailed:
            submitAlertViewController.dismiss(animated: true)
            showOneButtonAlert(with: "잠시 후 다시 시도해주세요.", storingIn: &subscriptions)
        }
    }
}

// MARK: - Navigation Items

extension DailyTestViewController {
    private func setNavigationItems() {
        let cancelButtonItem = UIBarButtonItem(
            title: "취소",
            style: .done,
            target: self,
            action: #selector(moveToHome)
        )
        cancelButtonItem.tintColor = .coolNeutral800
        navigationItem.leftBarButtonItem = cancelButtonItem
        navigationItem.rightBarButtonItem = contentView.timerBarButtonItem
    }

    private func removeNavigationItems() {
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = nil
    }

    @objc private func moveToHome() {
        input.send(.cancelButtonClicked)
    }
}

// MARK: - Alert

extension DailyTestViewController {
    private func setAlertButtonActions() {
        let confirmAction = UIAction { [weak self] _ in
            guard let self else { return }
            self.input.send(.alertSubmitButtonClicked)
        }
        let cancelAction = UIAction { [weak self] _ in
            guard let self else { return }
            self.input.send(.alertCancelButtonClicked)
        }
        submitAlertViewController.setupButtonActions(
            confirmAction: confirmAction,
            cancelAction: cancelAction
        )
    }
}
