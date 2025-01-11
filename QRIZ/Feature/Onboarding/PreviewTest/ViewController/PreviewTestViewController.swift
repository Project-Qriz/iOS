//
//  PreviewTestViewController.swift
//  QRIZ
//
//  Created by ch on 12/14/24.
//

import UIKit
import Combine

final class PreviewTestViewController: UIViewController {
    
    private let questionNumberLabel = QuestionNumberLabel(0)
    private let questionTitleLabel = QuestionTitleLabel("")
    private let option1Label = QuestionOptionLabel(optNum: 1, optStr: "")
    private let option2Label = QuestionOptionLabel(optNum: 2, optStr: "")
    private let option3Label = QuestionOptionLabel(optNum: 3, optStr: "")
    private let option4Label = QuestionOptionLabel(optNum: 4, optStr: "")
    private let previousButton: TestButton = TestButton(isPreviousButton: true)
    private let nextButton: TestButton = TestButton(isPreviousButton: false)
    private let progressView: TestProgressView = TestProgressView()
    private let timeLabel: TestTimeLabel = TestTimeLabel()
    private let totalTimeRemainingLabel: TestTotalTimeRemainingLabel = TestTotalTimeRemainingLabel()
    private let pageIndicatorLabel: TestPageIndicatorLabel = TestPageIndicatorLabel()
    private let submitAlert = CustomAlertView(alertType: .canCancel, title: "제출하시겠습니까", description: "확인 버튼을 누르면 다시 돌아올 수 없어요.", descriptionLine: 1)
    private let submitAlertViewController = CustomAlertViewController()
    
    private let viewModel: PreviewTestViewModel = PreviewTestViewModel()
    private var subscriptions = Set<AnyCancellable>()
    private let input: PassthroughSubject<PreviewTestViewModel.Input, Never> = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .customBlue50
        bind()
        setNavigationItem()
        addViews()
        setOptionActions()
        setButtonActions()
        setAlertController()
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
    
    private func setAlertController() {
        setAlertButtonActions()
        submitAlertViewController.setAlertView(alertView: submitAlert)
    }
    
    private func setAlertButtonActions() {
        submitAlert.setButtonAction(true, action: UIAction(handler: { [weak self] _ in
            guard let self = self else { return }
            self.input.send(.alertSubmitButtonClicked)
        }))
        submitAlert.setButtonAction(false, action: UIAction(handler: { [weak self] _ in
            guard let self = self else { return }
            self.input.send(.alertCancelButtonClicked)
        }))
    }
    
    private func setNavigationItem() {
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(moveToHome))
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(customView: timeLabel), UIBarButtonItem(customView: totalTimeRemainingLabel)
        ]
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
    
    func formattedTime(timeRemaining: Int) -> String {
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
            questionNumberLabel.widthAnchor.constraint(equalToConstant: 35),
            questionNumberLabel.heightAnchor.constraint(equalToConstant: 30),
            questionTitleLabel.topAnchor.constraint(equalTo: questionNumberLabel.topAnchor, constant: 5),
            questionTitleLabel.leadingAnchor.constraint(equalTo: questionNumberLabel.trailingAnchor, constant: 9),
            questionTitleLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -18),
            questionTitleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 22),
            option1Label.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 18),
            option1Label.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -18),
            option1Label.bottomAnchor.constraint(equalTo: option2Label.topAnchor, constant: -10),
            option1Label.heightAnchor.constraint(equalToConstant: 50),
            option2Label.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 18),
            option2Label.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -18),
            option2Label.bottomAnchor.constraint(equalTo: option3Label.topAnchor, constant: -10),
            option2Label.heightAnchor.constraint(equalToConstant: 50),
            option3Label.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 18),
            option3Label.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -18),
            option3Label.bottomAnchor.constraint(equalTo: option4Label.topAnchor, constant: -10),
            option3Label.heightAnchor.constraint(equalToConstant: 50),
            option4Label.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 18),
            option4Label.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -18),
            option4Label.bottomAnchor.constraint(equalTo: previousButton.topAnchor, constant:  -8),
            option4Label.heightAnchor.constraint(equalToConstant: 50),
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
        
        self.view.bringSubviewToFront(questionTitleLabel)
    }
}
