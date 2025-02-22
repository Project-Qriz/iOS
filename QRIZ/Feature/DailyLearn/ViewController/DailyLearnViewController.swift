//
//  DailyLearnViewController.swift
//  QRIZ
//
//  Created by 이창현 on 2/15/25.
//

import UIKit
import Combine

final class DailyLearnViewController: UIViewController {
    
    // MARK: - Properties
    private var day: Int
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .customBlue50
        return scrollView
    }()
    private let scrollInnerView: UIView = .init()
    private let studyContentTitleLabel: DailyLearnSectionTitleLabel = .init()
    private let studyContentView: StudyContentView = .init()
    private let testSubtextLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .coolNeutral500
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    private let relatedTestTitleLabel: DailyLearnSectionTitleLabel = .init()
    private let testNavigator: TestNavigatorButton = .init()
    
    private let viewModel: DailyLearnViewModel = .init()
    private let input: PassthroughSubject<DailyLearnViewModel.Input, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Initializer
    init(day: Int) {
        self.day = day
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: DailyLearnViewController")
    }
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarTitle(title: "오늘의 공부")
        bind()
        input.send(.viewDidLoad(day: day))
        addViews()
    }
    
    private func bind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .fetchSuccess(let state, let type, let score):
                    setTitleLabels(type: type)
                    setTestSubtextLabel(state: state)
                    setNavigatorButton(state: state, type: type, score: score)
                    setNavigatorButtonHeight(state: state)
                case .fetchFailed:
                    print("Fetch Failed")
                case .updateContent(let keyConcept1, let conceptContent1, let keyConcept2, let conceptContent2):
                    studyContentView.setLabelsText(keyConcept1: keyConcept1, conceptContent1: conceptContent1, keyConcept2: keyConcept2, conceptContent2: conceptContent2)
                case .moveToDailyTest(let isRetest):
                    // modal will be added
                    print("MOVE TO DAILY TEST")
                case .moveToDailyTestResult:
                    print("MOVE TO DAILY TEST RESULT")
                }
            }
            .store(in: &subscriptions)
    }
    
    private func setTitleLabels(type: DailyLearnType) {
        studyContentTitleLabel.setText(isStudyContentTitle: true, type: type)
        relatedTestTitleLabel.setText(isStudyContentTitle: false)
    }
    
    private func setTestSubtextLabel(state: DailyTestState) {
        switch state {
        case .unavailable:
            testSubtextLabel.text = "이전 테스트를 학습 완료했는지 확인해주세요!"
        case .zeroAttempt:
            testSubtextLabel.text = "아래의 테스트를 학습 완료해야만 다음 데일리 테스트를 진행할 수 있습니다!"
        case .passed:
            testSubtextLabel.text = "학습완료. 수고하셨어요!"
        case .retestRequired:
            testSubtextLabel.text = "점수 미달인 경우 재시험을 볼 수 있습니다."
        case .failed:
            testSubtextLabel.text = "학습완료. 수고하셨어요!"
        }
    }
    
    private func setNavigatorButton(state: DailyTestState, type: DailyLearnType, score: Int?) {
        testNavigator.setDailyUI(state: state, type: type, score: score)
    }
}

// MARK: - Auto Layout
extension DailyLearnViewController {
    private func addViews() {
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(scrollInnerView)
        self.scrollInnerView.addSubview(studyContentTitleLabel)
        self.scrollInnerView.addSubview(studyContentView)
        self.scrollInnerView.addSubview(testSubtextLabel)
        self.scrollInnerView.addSubview(relatedTestTitleLabel)
        self.scrollInnerView.addSubview(testNavigator)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollInnerView.translatesAutoresizingMaskIntoConstraints = false
        studyContentTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        studyContentView.translatesAutoresizingMaskIntoConstraints = false
        testSubtextLabel.translatesAutoresizingMaskIntoConstraints = false
        relatedTestTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        testNavigator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            
            scrollInnerView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            scrollInnerView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            scrollInnerView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            scrollInnerView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            scrollInnerView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            studyContentTitleLabel.topAnchor.constraint(equalTo: scrollInnerView.topAnchor, constant: 25),
            studyContentTitleLabel.leadingAnchor.constraint(equalTo: scrollInnerView.leadingAnchor, constant: 18),
            
            studyContentView.topAnchor.constraint(equalTo: studyContentTitleLabel.bottomAnchor, constant: 17),
            studyContentView.leadingAnchor.constraint(equalTo: scrollInnerView.leadingAnchor, constant: 18),
            studyContentView.trailingAnchor.constraint(equalTo: scrollInnerView.trailingAnchor, constant: -18),
            
            testSubtextLabel.topAnchor.constraint(equalTo: studyContentView.bottomAnchor, constant: 32),
            testSubtextLabel.leadingAnchor.constraint(equalTo: scrollInnerView.leadingAnchor, constant: 18),
            testSubtextLabel.trailingAnchor.constraint(equalTo: scrollInnerView.trailingAnchor, constant: 18),
            
            relatedTestTitleLabel.topAnchor.constraint(equalTo: testSubtextLabel.bottomAnchor, constant: 19),
            relatedTestTitleLabel.leadingAnchor.constraint(equalTo: scrollInnerView.leadingAnchor, constant: 18),
            relatedTestTitleLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -18),
            
            testNavigator.topAnchor.constraint(equalTo: relatedTestTitleLabel.bottomAnchor, constant: 18),
            testNavigator.leadingAnchor.constraint(equalTo: scrollInnerView.leadingAnchor, constant: 18),
            testNavigator.trailingAnchor.constraint(equalTo: scrollInnerView.trailingAnchor, constant: -18),
            testNavigator.bottomAnchor.constraint(equalTo: scrollInnerView.bottomAnchor, constant: -100)
        ])
    }
    
    private func setNavigatorButtonHeight(state: DailyTestState) {
        let buttonHeight = (state == .retestRequired ? 153.0 : 116.0)
        testNavigator.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
    }
}
