//
//  DailyResultViewController.swift
//  QRIZ
//
//  Created by 이창현 on 4/1/25.
//

import UIKit
import Combine

final class DailyResultViewController: UIViewController {
    
    // MARK: - Properties
    private var dailyResultViewHostingController: DailyResultViewHostingController!
    
    private let viewModel: DailyResultViewModel = .init(dailyTestType: .monthly)
    private let input: PassthroughSubject<DailyResultViewModel.Input, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setNavigationItems()
        addViews()
        bind()
        input.send(.viewDidLoad)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        input.send(.viewDidAppear)
    }
    
    private func bind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .moveToConcept:
                    print("Move To Concept")
                case .moveToDailyLearn:
                    print("Move To Daily Learn")
                }
            }
            .store(in: &subscriptions)
    }
    
    private func loadResultView() -> UIView {
        dailyResultViewHostingController = DailyResultViewHostingController(rootView: DailyResultView(resultScorsData: self.viewModel.resultScoresData, resultGradeListData: self.viewModel.resultGradeListData, dailyLearnType: self.viewModel.dailyTestType))
        self.addChild(dailyResultViewHostingController)
        dailyResultViewHostingController.didMove(toParent: self)

        let resultView = dailyResultViewHostingController.view ?? UIView(frame: .zero)
        return resultView
    }
    
    private func setNavigationItems() {
        let titleView = UILabel()
        titleView.text = "시험 결과"
        titleView.font = .boldSystemFont(ofSize: 18)
        titleView.textAlignment = .center
        titleView.textColor = .coolNeutral700
        self.navigationItem.titleView = titleView
        
        let xmark = UIImage(systemName: "xmark")?.withTintColor(.coolNeutral800, renderingMode: .alwaysOriginal)
        let button = UIButton(frame: CGRectMake(0, 0, 28, 28))
        button.setImage(xmark, for: .normal)
        button.addTarget(self, action: #selector(cancelTestResult), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    @objc private func cancelTestResult() {
        input.send(.cancelButtonClicked)
    }
}

// MARK: - AutoLayout
extension DailyResultViewController {
    private func addViews() {
        let dailyResultView = loadResultView()
        self.view.addSubview(dailyResultView)
        
        dailyResultView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dailyResultView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            dailyResultView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            dailyResultView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            dailyResultView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
