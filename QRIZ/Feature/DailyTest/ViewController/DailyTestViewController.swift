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
    
    private let viewModel: DailyTestViewModel = .init()
    private let input: PassthroughSubject<DailyTestViewModel.Input, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setNavigationItems()
        bind()
        addViews()
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
                case .fetchFailed:
                    print("DailyTestViewModel failed to fetch")
                case .updateQuestion(let question):
                    contentsView.updateQuestion(question)
                    footerView.updateCurPage(curPage: question.questionNumber)
                case .updateTotalPage(let totalPage):
                    footerView.updateTotalPage(totalPage: totalPage)
                case .updateTime(let timeLimit, let timeRemaining):
                    updateProgress(timeLimit: timeLimit, timeRemaining: timeRemaining)
                case .updateOptionState(let optionIdx, let isSelected):
                    contentsView.setOptionState(optionIdx: optionIdx, isSelected: isSelected)
                case .moveToDailyResult:
                    print("Move To Daily Result")
                case .moveToHomeView:
                    // Coordinator role
                    print("Move To Home View")
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
    
    @objc private func moveToHome() {
        input.send(.cancelButtonClicked)
    }
    
    private func updateProgress(timeLimit: Int, timeRemaining: Int) {
        timerLabel.updateTime(timeRemaining: timeRemaining)
        progressView.progress = Float(timeLimit - timeRemaining) / Float(timeLimit)
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
