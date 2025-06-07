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
    private var selectedOptionIdx: Int? = nil
    private var lastQuestionNum: Int = 0
    private var curNum: Int = 0
    
    private let questionNumberLabel = QuestionNumberLabel()
    private let questionTitleLabel = QuestionTitleLabel()
    private let optionLabels: [QuestionOptionLabel] = {
        var arr: [QuestionOptionLabel] = []
        for i in 1...4 {
            arr.append(QuestionOptionLabel(optNum: i))
        }
        return arr
    }()
    private let previousButton: TestButton = TestButton(isPreviousButton: true)
    private let nextButton: TestButton = TestButton(isPreviousButton: false)
    private let progressView: TestProgressView = TestProgressView()
    private let timeLabel: TestTimeLabel = TestTimeLabel()
    private let totalTimeRemainingLabel: TestTotalTimeRemainingLabel = TestTotalTimeRemainingLabel()
    private let pageIndicatorBgView: UIView = {
        let view = UIView()
        view.backgroundColor = .white

        view.layer.shadowColor = UIColor.customBlue100.cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 16
        return view
    }()
    private let pageIndicatorLabel: TestPageIndicatorLabel = TestPageIndicatorLabel()
    private let cancelLabel: UILabel = {
        let label = UILabel()
        label.textColor = .coolNeutral800
        label.text = "취소"
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    private let submitAlertViewController = TwoButtonCustomAlertViewController(title: "제출하시겠습니까?", description: "확인 버튼을 누르면 다시 돌아올 수 없어요.")
    
    private let viewModel: PreviewTestViewModel
    private var subscriptions = Set<AnyCancellable>()
    private let input: PassthroughSubject<PreviewTestViewModel.Input, Never> = .init()
    
    weak var coordinator: OnboardingCoordinator?
    
    // MARK: - Initializers
    init(viewModel: PreviewTestViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
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
    
    private func bind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        
        output
            .receive(on: RunLoop.main)
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .fetchFailed:
                    self.showOneButtonAlert(with: "문제 불러오기 실패", for: "잠시 후 다시 시도해주세요.", storingIn: &subscriptions)
                case .updateQuestion(let question, let curNum, let selectedOption):
                    updateQuestionUI(question: question, curNum: curNum, selectedOption: selectedOption)
                case .updateLastQuestionNum(let num):
                    self.lastQuestionNum = num
                case .updateTime(let timeLimit, let timeRemaining):
                    updateProgress(timeLimit: timeLimit, timeRemaining: timeRemaining)
                case .moveToPreviewResult:
                    self.coordinator?.showPreviewResult()
                case .moveToHome:
                    if let coordinator = self.coordinator {
                        coordinator.delegate?.didFinishOnboarding(coordinator)
                    }
                case .popUpAlert:
                    present(submitAlertViewController, animated: true)
                case .cancelAlert:
                    submitAlertViewController.dismiss(animated: true)
                case .submitSuccess:
                    submitAlertViewController.dismiss(animated: true)
                case .submitFail:
                    submitAlertViewController.dismiss(animated: true)
                    self.showOneButtonAlert(with: "잠시 후 다시 시도해주세요.", storingIn: &subscriptions)
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
    
    private func updateQuestionUI(question: PreviewTestListQuestion, curNum: Int, selectedOption: Int?) {
        self.curNum = curNum
        let optStringArr: [String] = question.options.map { question in
            question.content
        }
        questionNumberLabel.setNumber(curNum)
        questionTitleLabel.setTitle(question.question)
        setSelectedOption(selectedOption)
        setOptionsString(optStringArr)
        pageIndicatorLabel.setCurPage(curPage: curNum)
        pageIndicatorLabel.setTotalPage(totalPage: lastQuestionNum)
        setPageButtonsUI(curNum)
    }
}

// MARK: - Methods For Options
extension PreviewTestViewController {
    private func setOptionsString(_ optStringArr: [String]) {
        for i in 0...3 {
            optionLabels[i].setOptionString(optStringArr[i])
        }
    }
    
    private func setSelectedOption(_ selectedOption: Int?) {
        if let selectedOptionIdx = selectedOptionIdx {
            setOptionState(idx: selectedOptionIdx, isSelected: false)
        }
        if let selectedOption = selectedOption {
            setOptionState(idx: selectedOption, isSelected: true)
        }
        selectedOptionIdx = selectedOption
    }
    
    private func setOptionActions() {
        for (index, optionLabel) in optionLabels.enumerated() {
            optionLabel.isUserInteractionEnabled = true
            optionLabel.tag = index + 1
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(optionTouchEvent(_:)))
            optionLabel.addGestureRecognizer(tapGesture)
        }
    }
    
    @objc private func optionTouchEvent(_ sender: UITapGestureRecognizer) {
        guard let idx = sender.view?.tag else { return }
        
        if let selectedOptionIdx = selectedOptionIdx {
            if selectedOptionIdx == idx {
                setOptionState(idx: idx, isSelected: false)
                self.selectedOptionIdx = nil
            } else {
                setOptionState(idx: selectedOptionIdx, isSelected: false)
                setOptionState(idx: idx, isSelected: true)
                self.selectedOptionIdx = idx
            }
        } else {
            setOptionState(idx: idx, isSelected: true)
            self.selectedOptionIdx = idx
        }
        
        if curNum == 1 {
            selectedOptionIdx == nil ? setButtonsVisibility(isFirstQuestion: true, isOptionSelected: false) : setButtonsVisibility(isFirstQuestion: true, isOptionSelected: true)
        }
    }
    
    private func setOptionState(idx: Int, isSelected: Bool) {
        switch idx {
        case 1...4:
            optionLabels[idx - 1].setOptionState(isSelected: isSelected)
        default:
            print("error occured while setting option state in PreviewTestViewController")
        }
    }
}

// MARK: - Methods For Progress
extension PreviewTestViewController {
    private func updateProgress(timeLimit: Int, timeRemaining: Int) {
        progressView.progress = Float(timeRemaining) / Float(timeLimit)
        timeLabel.text = formattedTime(timeRemaining: timeRemaining)
    }
    
    private func formattedTime(timeRemaining: Int) -> String {
        return timeRemaining.formattedTime
    }
}

// MARK: - Methods For Previous & Next Button
extension PreviewTestViewController {
    private func setButtonActions() {
        self.previousButton.addAction(UIAction(handler: { [weak self] _ in
            guard let self = self else { return }
            self.input.send(.prevButtonClicked(selectedOption: selectedOptionIdx))
        }), for: .touchUpInside)
        self.nextButton.addAction(UIAction(handler: { [weak self] _ in
            guard let self = self else { return }
            self.input.send(.nextButtonClicked(selectedOption: selectedOptionIdx))
        }), for: .touchUpInside)
    }
    
    private func setPageButtonsUI(_ questionNum: Int) {
        switch questionNum {
        case 1:
            selectedOptionIdx == nil ? setButtonsVisibility(isFirstQuestion: true, isOptionSelected: false) : setButtonsVisibility(isFirstQuestion: true, isOptionSelected: true)
        case 2:
            setButtonsVisibility(isFirstQuestion: false)
        case lastQuestionNum - 1:
            setNextButtonTitle(isLastQuestion: false)
        case lastQuestionNum:
            setNextButtonTitle(isLastQuestion: true)
        default:
            return
        }
    }
    
    private func setNextButtonTitle(isLastQuestion: Bool) {
        if isLastQuestion {
            nextButton.setTitleText("제출")
        } else {
            nextButton.setTitleText("다음")
        }
    }
    
    private func setButtonsVisibility(isFirstQuestion: Bool, isOptionSelected: Bool = false) {
        if isFirstQuestion {
            previousButton.isHidden = true
            nextButton.isHidden = !isOptionSelected
        } else {
            previousButton.isHidden = false
            nextButton.isHidden = false
        }
    }
}

// MARK: - Auto Layout
extension PreviewTestViewController {
    private func addViews() {
        self.view.addSubview(progressView)
        self.view.addSubview(questionNumberLabel)
        self.view.addSubview(questionTitleLabel)
        self.view.addSubview(pageIndicatorBgView)
        self.view.addSubview(previousButton)
        self.view.addSubview(nextButton)
        self.view.addSubview(pageIndicatorLabel)
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        questionNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        questionTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        pageIndicatorBgView.translatesAutoresizingMaskIntoConstraints = false
        previousButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        pageIndicatorLabel.translatesAutoresizingMaskIntoConstraints = false

        for optionLabel in optionLabels {
            self.view.addSubview(optionLabel)
            optionLabel.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            progressView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 4),

            questionNumberLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 18),
            questionNumberLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 40),

            questionTitleLabel.leadingAnchor.constraint(equalTo: questionNumberLabel.leadingAnchor),
            questionTitleLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -18),
            questionTitleLabel.topAnchor.constraint(equalTo: questionNumberLabel.bottomAnchor, constant: 14),
            
            pageIndicatorBgView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            pageIndicatorBgView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            pageIndicatorBgView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -108),
            pageIndicatorBgView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            previousButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 18),
            previousButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            previousButton.widthAnchor.constraint(equalToConstant: 90),
            previousButton.heightAnchor.constraint(equalToConstant: 48),

            nextButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -18),
            nextButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            nextButton.widthAnchor.constraint(equalToConstant: 90),
            nextButton.heightAnchor.constraint(equalToConstant: 48),

            pageIndicatorLabel.leadingAnchor.constraint(equalTo: previousButton.trailingAnchor),
            pageIndicatorLabel.trailingAnchor.constraint(equalTo: nextButton.leadingAnchor),
            pageIndicatorLabel.centerYAnchor.constraint(equalTo: previousButton.centerYAnchor),
            pageIndicatorLabel.heightAnchor.constraint(equalToConstant: 22)
        ])
        
        setOptionLabelLayout()
        
        self.view.bringSubviewToFront(questionTitleLabel)
    }
    
    private func setOptionLabelLayout() {
        for (idx, option) in optionLabels.enumerated() {
            NSLayoutConstraint.activate([
                option.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 18),
                option.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -18),
            ])
            
            if idx != 0 {
                option.topAnchor.constraint(equalTo: optionLabels[idx - 1].bottomAnchor).isActive = true
            } else {
                optionLabels[0].topAnchor.constraint(equalTo: questionTitleLabel.bottomAnchor, constant: 26).isActive = true
            }
        }
    }
}
