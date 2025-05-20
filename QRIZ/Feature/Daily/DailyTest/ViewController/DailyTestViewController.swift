//
//  DailyTestViewController.swift
//  QRIZ
//
//  Created by 이창현 on 4/1/25.
//

import UIKit
import Combine

final class DailyTestViewController: UIViewController {
    
    // MARK: - Properties
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        return scrollView
    }()
    private let progressView: TestProgressView = .init()
    private let footerView: DailyTestFooterView = .init()
    private let contentsView: DailyTestContentsView = .init()
    private let timerLabel: DailyTestTimerLabel = .init()
    
    private let viewModel: DailyTestViewModel
    private let input: PassthroughSubject<DailyTestViewModel.Input, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    private let submitAlertViewController = TwoButtonCustomAlertViewController(title: "제출하시겠습니까?", description: "확인 버튼을 누르면 다시 돌아올 수 없어요.")
    
    // MARK: - Initializers
    init(viewModel: DailyTestViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: DailyTestViewController")
    }

    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setNavigationItems()
        bind()
        addViews()
        setAlertButtonActions()
        input.send(.viewDidLoad)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        input.send(.viewDidAppear)
    }
    
    private func bind() {
        let mergedInput = input.merge(with: contentsView.input, footerView.input)
        let output = viewModel.transform(input: mergedInput.eraseToAnyPublisher())
        
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .fetchFailed(let isServerError):
                    if isServerError {
                        showOneButtonAlert(with: "Server Error", for: "관리자에게 문의하세요.", storingIn: &subscriptions)
                    } else {
                        showOneButtonAlert(with: "잠시 후 다시 시도해주세요.", storingIn: &subscriptions)
                    }
                case .updateQuestion(let question):
                    contentsView.updateQuestion(question)
                    footerView.updateCurPage(curPage: question.questionNumber)
                    scrollView.setContentOffset(.zero, animated: false)
                case .updateTotalPage(let totalPage):
                    footerView.updateTotalPage(totalPage: totalPage)
                case .updateTime(let timeLimit, let timeRemaining):
                    updateProgress(timeLimit: timeLimit, timeRemaining: timeRemaining)
                case .updateOptionState(let optionIdx, let isSelected):
                    contentsView.setOptionState(optionIdx: optionIdx, isSelected: isSelected)
                case .setButtonVisibility(let isVisible):
                    footerView.setButtonsVisibility(isVisible: isVisible)
                case .alterButtonText:
                    footerView.alterButtonText()
                case .moveToDailyResult(let type, let day):
                    self.navigationController?.pushViewController(DailyResultViewController(viewModel: DailyResultViewModel(dailyTestType: type, day: day, dailyService: DailyServiceImpl())), animated: true)
                case .moveToHomeView:
                    print("Move To Home View")
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
            .store(in: &subscriptions)
    }
    
    private func setNavigationItems() {
        let cancelButtonItem = UIBarButtonItem(title: "취소", style: .done, target: self, action: #selector(moveToHome))
        cancelButtonItem.tintColor = .coolNeutral800
        navigationItem.leftBarButtonItem = cancelButtonItem
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: timerLabel)
    }
    
    private func removeNavigationItems() {
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = nil
    }
    
    @objc private func moveToHome() {
        input.send(.cancelButtonClicked)
    }
    
    private func updateProgress(timeLimit: Int, timeRemaining: Int) {
        timerLabel.updateTime(timeRemaining: timeRemaining)
        progressView.progress = Float(timeLimit - timeRemaining) / Float(timeLimit)
    }
    
    private func setAlertButtonActions() {
        let confirmAction = UIAction { [weak self] _ in
            guard let self = self else { return }
            self.input.send(.alertSubmitButtonClicked)
        }
        
        let cancelAction = UIAction { [weak self] _ in
            guard let self = self else { return }
            self.input.send(.alertCancelButtonClicked)
        }
        
        submitAlertViewController.setupButtonActions(confirmAction: confirmAction, cancelAction: cancelAction)
    }
}

// Auto Layout
extension DailyTestViewController {
    private func addViews() {
        self.view.addSubview(progressView)
        self.view.addSubview(scrollView)
        scrollView.addSubview(contentsView)
        self.view.addSubview(footerView)
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentsView.translatesAutoresizingMaskIntoConstraints = false
        contentsView.translatesAutoresizingMaskIntoConstraints = false
        footerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            progressView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 4),
            
            footerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: 132),
            
            scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 18),
            scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -18),
            scrollView.topAnchor.constraint(equalTo: progressView.bottomAnchor),
            scrollView.bottomAnchor.constraint(equalTo: footerView.topAnchor),
            
            contentsView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentsView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentsView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentsView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentsView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
    }
}
