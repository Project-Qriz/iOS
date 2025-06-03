//
//  DailyResultDetailViewController.swift
//  QRIZ
//
//  Created by 이창현 on 4/19/25.
//

import UIKit
import Combine

final class TestResultDetailViewController: UIViewController {
    
    // MARK: - Properties
    private var dailyResultDetailHostingController: ResultDetailHostingController!

    private let viewModel: TestResultDetailViewModel
    private let input: PassthroughSubject<TestResultDetailViewModel.Input, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Initializers
    init(viewModel: TestResultDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        addViews()
        bind()
    }
    
    private func bind() {
        let mergedInput = input.merge(with: dailyResultDetailHostingController.rootView.input)
        viewModel.transform(input: mergedInput.eraseToAnyPublisher())
    }
    
    private func loadDetailView() -> UIView {
        dailyResultDetailHostingController = ResultDetailHostingController(
            rootView: ResultDetailView(
                resultScoreData: self.viewModel.resultScoresData,
                resultDetailData: self.viewModel.resultDetailData))
        self.addChild(dailyResultDetailHostingController)
        dailyResultDetailHostingController.didMove(toParent: self)
        
        let detailView = dailyResultDetailHostingController.view ?? UIView(frame: .zero)
        return detailView
    }
}

// MARK: - Auto Layout
extension TestResultDetailViewController {
    private func addViews() {
        let resultDetailView = loadDetailView()
        self.view.addSubview(resultDetailView)
        
        resultDetailView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            resultDetailView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            resultDetailView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            resultDetailView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            resultDetailView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }
}
