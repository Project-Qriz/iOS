//
//  PreviewTestViewController.swift
//  QRIZ
//
//  Created by ch on 12/14/24.
//

import UIKit
import Combine

final class PreviewTestViewController: UIViewController {
    
    // MARK: - Properties
    private let questionNumberLabel = QuestionNumberLabel(0)
    private let questionTitleLabel = QuestionTitleLabel("")
    private let option1Label = QuestionOptionLabel(optNum: 1)
    private let option2Label = QuestionOptionLabel(optNum: 2)
    private let option3Label = QuestionOptionLabel(optNum: 3)
    private let option4Label = QuestionOptionLabel(optNum: 4)
    private let previousButton: TestButton = TestButton(isPreviousButton: true)
    private let nextButton: TestButton = TestButton(isPreviousButton: false)
    private let progressView: TestProgressView = TestProgressView()
    private let timeLabel: TestTimeLabel = TestTimeLabel()
    private let totalTimeRemainingLabel: TestTotalTimeRemainingLabel = TestTotalTimeRemainingLabel()
    private let pageIndicatorLabel: TestPageIndicatorLabel = TestPageIndicatorLabel()
    private let cancelLabel: UILabel = {
        let label = UILabel()
        label.textColor = .coolNeutral800
        label.text = "취소"
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    private let submitAlertViewController = TwoButtonCustomAlertViewController(title: "제출하시겠습니까?", description: "확인 버튼을 누르면 다시 돌아올 수 없어요.")
    
    private let viewModel: PreviewTestViewModel = PreviewTestViewModel()
    private var subscriptions = Set<AnyCancellable>()
    private let input: PassthroughSubject<PreviewTestViewModel.Input, Never> = .init()
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        bind()
        setNavigationItem()
        addViews()
        setOptionActions()
        setButtonActions()
        setAlertButtonActions()
        input.send(.viewDidLoad)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        input.send(.viewDidAppear)
    }
    
    private func bind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        
        output
            .receive(on: RunLoop.main)
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .selectOption(let idx):
                    setOptionState(idx: idx, isSelected: true)
                case .deselectOption(let idx):
                    setOptionState(idx: idx, isSelected: false)
                case .updateQuestion(let question):
                    updateQuestionUI(question: question)
                case .updateTime(let timeLimit, let timeRemaining):
                    updateProgress(timeLimit: timeLimit, timeRemaining: timeRemaining)
                case .updateNextButton(let isLastQuestion):
                    setNextButtonTitle(isLastQuestion: isLastQuestion)
                case .moveToPreviewResult:
                    self.navigationController?.pushViewController(PreviewResultViewController(), animated: true)
                case .moveToHome:
                    self.dismiss(animated: true)
                case .popUpAlert:
                    present(submitAlertViewController, animated: true) // coordniator role
                case .cancelAlert:
                    submitAlertViewController.dismiss(animated: true) // coordinator role
                case .submitSuccess:
                    submitAlertViewController.dismiss(animated: true) // coordinator role
                    print("submit success")
                case .submitFail:
                    print("Preview test submit failed..") // network error
                }
            }
            .store(in: &subscriptions)
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
    
    private func setNavigationItem() {
        self.navigationController?.navigationBar.isHidden = false
        setCancelLabelAction()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelLabel)
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(customView: timeLabel), UIBarButtonItem(customView: totalTimeRemainingLabel)
        ]
    }
    
    private func setCancelLabelAction() {
        cancelLabel.isUserInteractionEnabled = true
        cancelLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(moveToHome)))
    }
    
    @objc private func moveToHome() {
        input.send(.escapeButtonClicked)
    }
    
    private func setOptionActions() {
        
        let optionLabels = [option1Label, option2Label, option3Label, option4Label]
        
        for (index, optionLabel) in optionLabels.enumerated() {
            optionLabel.isUserInteractionEnabled = true
            optionLabel.tag = index + 1
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(sendOptionTouchEvent(_:)))
            optionLabel.addGestureRecognizer(tapGesture)
        }
    }
    
    @objc private func sendOptionTouchEvent(_ sender: UITapGestureRecognizer) {
        
        let idx = sender.view?.tag ?? 0
        input.send(.optionSelected(idx: idx))
    }
    
    private func setOptionState(idx: Int, isSelected: Bool) {
        switch idx {
        case 1:
            option1Label.setOptionStatus(isSelected: isSelected)
        case 2:
            option2Label.setOptionStatus(isSelected: isSelected)
        case 3:
            option3Label.setOptionStatus(isSelected: isSelected)
        case 4:
            option4Label.setOptionStatus(isSelected: isSelected)
        default:
            print("error occured while setting option state in PreviewTestViewController")
        }
    }
    
    private func updateQuestionUI(question: QuestionData) {
        questionNumberLabel.setNumber(question.questionNumber)
        questionTitleLabel.setTitle(question.question)
        option1Label.setOptionString(question.option1)
        option2Label.setOptionString(question.option2)
        option3Label.setOptionString(question.option3)
        option4Label.setOptionString(question.option4)
        pageIndicatorLabel.setPages(curPage: question.questionNumber, totalPage: 20)
    }
    
    private func updateProgress(timeLimit: Int, timeRemaining: Int) {
        progressView.progress = Float(timeRemaining) / Float(timeLimit)
        timeLabel.text = formattedTime(timeRemaining: timeRemaining)
    }
    
    private func formattedTime(timeRemaining: Int) -> String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func setButtonActions() {
        self.previousButton.addAction(UIAction(handler: { [weak self] _ in
            guard let self = self else { return }
            self.input.send(.prevButtonClicked)
        }), for: .touchUpInside)
        self.nextButton.addAction(UIAction(handler: { [weak self] _ in
            guard let self = self else { return }
            self.input.send(.nextButtonClicked)
        }), for: .touchUpInside)
    }
    
    private func setNextButtonTitle(isLastQuestion: Bool) {
        if isLastQuestion {
            nextButton.setTitleText("제출")
        } else {
            nextButton.setTitleText("다음")
        }
    }
}

// MARK: - AutoLayout
extension PreviewTestViewController {
    private func addViews() {
        self.view.addSubview(progressView)
        self.view.addSubview(questionNumberLabel)
        self.view.addSubview(questionTitleLabel)
        self.view.addSubview(option1Label)
        self.view.addSubview(option2Label)
        self.view.addSubview(option3Label)
        self.view.addSubview(option4Label)
        self.view.addSubview(previousButton)
        self.view.addSubview(nextButton)
        self.view.addSubview(pageIndicatorLabel)
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        questionNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        questionTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        option1Label.translatesAutoresizingMaskIntoConstraints = false
        option2Label.translatesAutoresizingMaskIntoConstraints = false
        option3Label.translatesAutoresizingMaskIntoConstraints = false
        option4Label.translatesAutoresizingMaskIntoConstraints = false
        previousButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        pageIndicatorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            progressView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 4),

            questionNumberLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 40),
            questionNumberLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 18),

            questionTitleLabel.topAnchor.constraint(equalTo: questionNumberLabel.bottomAnchor, constant: 14),
            questionTitleLabel.leadingAnchor.constraint(equalTo: questionNumberLabel.leadingAnchor),
            questionTitleLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -18),

            previousButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 18),
            previousButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            previousButton.widthAnchor.constraint(equalToConstant: 90),
            previousButton.heightAnchor.constraint(equalToConstant: 48),

            nextButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -18),
            nextButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            nextButton.widthAnchor.constraint(equalToConstant: 90),
            nextButton.heightAnchor.constraint(equalToConstant: 48),

            pageIndicatorLabel.centerYAnchor.constraint(equalTo: previousButton.centerYAnchor),
            pageIndicatorLabel.leadingAnchor.constraint(equalTo: previousButton.trailingAnchor),
            pageIndicatorLabel.trailingAnchor.constraint(equalTo: nextButton.leadingAnchor),
            pageIndicatorLabel.heightAnchor.constraint(equalToConstant: 22)
        ])
        
        setOptionLabelLayout()
        
        self.view.bringSubviewToFront(questionTitleLabel)
    }
    
    private func setOptionLabelLayout() {
        
        let optionLabels: [QuestionOptionLabel] = [option1Label, option2Label, option3Label, option4Label]
        
        for (idx, option) in optionLabels.enumerated() {
            NSLayoutConstraint.activate([
                option.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 18),
                option.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -18),
            ])
            
            if idx != 0 {
                option.topAnchor.constraint(equalTo: optionLabels[idx - 1].bottomAnchor).isActive = true
            } else {
                option1Label.topAnchor.constraint(equalTo: questionTitleLabel.bottomAnchor, constant: 26).isActive = true
            }
        }
    }
}
