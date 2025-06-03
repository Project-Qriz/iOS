//
//  ExamTestViewController.swift
//  QRIZ
//
//  Created by ch on 5/21/25.
//

import UIKit
import Combine

final class ExamTestViewController: UIViewController {
    
    // MARK: - Properties
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        return scrollView
    }()
    private let progressView: TestProgressView = .init()
    private let footerView: ExamTestFooterView = .init()
    private let contentsView: TestContentsView = .init()
    private let timeLabel: TestTimeLabel = TestTimeLabel()
    private let totalTimeRemainingLabel: TestTotalTimeRemainingLabel = TestTotalTimeRemainingLabel()

    private let viewModel: ExamTestViewModel
    private let input: PassthroughSubject<ExamTestViewModel.Input, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    private let submitAlertViewController = TwoButtonCustomAlertViewController(title: "제출하시겠습니까?", description: "확인 버튼을 누르면 다시 돌아올 수 없어요.")
    
    // MARK: - Initializers
    init(viewModel: ExamTestViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: ExamTestViewController")
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
        let optionTapped = contentsView.optionTappedPublisher.map { ExamTestViewModel.Input.optionTapped(optionIdx: $0)
        }
        let prevTapped = footerView.prevButtonTappedPublisher.map {
            ExamTestViewModel.Input.prevButtonClicked
        }
        let nextTapped = footerView.nextButtonTappedPublisher.map {
            ExamTestViewModel.Input.nextButtonClicked
        }
        let mergedInput = input.merge(with: optionTapped, prevTapped, nextTapped)
        
        let output = viewModel.transform(input: mergedInput.eraseToAnyPublisher())
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .fetchFailed(let isServerError):
                    submitAlertViewController.dismiss(animated: true)
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
                case .updatePrevButton(let isVisible):
                    footerView.updatePrevButton(isVisible: isVisible)
                case .updateNextButton(let isVisible, let isTextSubmit):
                    footerView.updateNextButton(isVisible: isVisible, isTextSubmit: isTextSubmit)
                case .moveToExamResult(let examId):
                    removeNavigationItems()
                    self.navigationController?.pushViewController(ExamResultViewController(viewModel: ExamResultViewModel(examId: examId, examService: ExamServiceImpl())), animated: true)
                case .moveToExamList:
                    removeNavigationItems()
                    self.dismiss(animated: true)
                case .popSubmitAlert:
                    present(submitAlertViewController, animated: true)
                case .cancelAlert:
                    submitAlertViewController.dismiss(animated: true)
                case .submitSuccess:
                    submitAlertViewController.dismiss(animated: true)
                case .submitFailed:
                    submitAlertViewController.dismiss(animated: true)
                    showOneButtonAlert(with: "잠시 후 다시 시도해주세요.", storingIn: &subscriptions)
                }
            }
            .store(in: &subscriptions)
    }
    
    private func setNavigationItems() {
        let cancelButtonItem = UIBarButtonItem(title: "취소", style: .done, target: self, action: #selector(moveToExamList))
        cancelButtonItem.tintColor = .coolNeutral800
        navigationItem.leftBarButtonItem = cancelButtonItem
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(customView: timeLabel),
            UIBarButtonItem(customView: totalTimeRemainingLabel)
        ]
    }
    
    @objc private func moveToExamList() {
        input.send(.cancelButtonClicked)
    }
    
    private func removeNavigationItems() {
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = nil
    }
    
    private func updateProgress(timeLimit: Int, timeRemaining: Int) {
        progressView.progress = Float(timeRemaining) / Float(timeLimit)
        timeLabel.text = timeRemaining.formattedTime
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

extension ExamTestViewController {
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
