//
//  UIPreviewResultViewController.swift
//  QRIZ
//
//  Created by ch on 12/28/24.
//

import UIKit
import SwiftUI
import Combine

final class PreviewResultViewController: UIViewController {

    // MARK: - Properties
    private var resultTitleLabel = PreviewResultTitleLabel(isTitleLabel: true)
    private var resultConceptLabel = PreviewResultTitleLabel(isTitleLabel: false)
    private var scoreHostingController: PreviewResultScoreHostingController!
    private var conceptBarHostingController: PreviewResultConceptBarGraphHostingController!
    private let resultScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        return scrollView
    }()
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    private var conceptSupplementLabel: UILabel = {
        let label = UILabel()
        label.text = "보충하면 좋은 개념 top2"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .coolNeutral700
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    private var firstTopicLabel = PreviewResultSingleSupplementConceptView()
    private var secondTopicLabel = PreviewResultSingleSupplementConceptView()
    
    private var viewModel = PreviewResultViewModel()
    private let input: PassthroughSubject<PreviewResultViewModel.Input, Never> = .init()
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
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        
        output
            .receive(on: RunLoop.main)
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .updateUI(let nickname, let firstConcept, let secondConcept):
                    setLabelText(nickname: nickname)
                    setConceptsToSupplementLabel(firstConcept: firstConcept, secondConcept: secondConcept)
                case .createDataFailed:
                    print("create Data Failed : PreviewResultViewController")
                    //
                case .moveToGreetingView:
                    // coordinator role
                    navigationController?.pushViewController(GreetingViewController(), animated: true)
                case .removeConceptBarGraphView:
                    setLayoutWithoutBarGraph()
                case .resizeConceptBarGraphView:
                    resizeConceptBarGarphView()
                }
            }
            .store(in: &subscriptions)
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
        self.dismiss(animated: true)
    }
    
    private func setLabelText(nickname: String) {
        resultTitleLabel.setLabelText(nickname: nickname)
        resultConceptLabel.setLabelText()
    }
    
    private func setConceptsToSupplementLabel (firstConcept: String, secondConcept: String) {
        firstTopicLabel.setConceptLabelText(topic: firstConcept)
        secondTopicLabel.setConceptLabelText(topic: secondConcept)
    }
    
    private func loadScoreCircularChartView() -> UIView {
        scoreHostingController = PreviewResultScoreHostingController(rootView: PreviewResultScoreView(previewScoresData: self.viewModel.previewScoresData))
        self.addChild(scoreHostingController)
        scoreHostingController.didMove(toParent: self)
        let scoreCircularCharView = scoreHostingController.view ?? UIView(frame: .zero)
        scoreCircularCharView.backgroundColor = .white
        return scoreCircularCharView
    }
    
    private func loadConceptBarGraphView() -> UIView {
        conceptBarHostingController = PreviewResultConceptBarGraphHostingController(rootView: PreviewResultConceptBarGraphView(previewConceptsData: self.viewModel.previewConceptsData))
        self.addChild(conceptBarHostingController)
        conceptBarHostingController.didMove(toParent: self)
        let conceptBarGraphView = conceptBarHostingController.view ?? UIView(frame: .zero)
        conceptBarGraphView.backgroundColor = .white
        return conceptBarGraphView
    }
}

// MARK: - Auto Layout
extension PreviewResultViewController {

    private func addViews() {
        
        let scoreView = loadScoreCircularChartView()
        let conceptBarGraphView = loadConceptBarGraphView()
        
        self.view.addSubview(resultScrollView)
        resultScrollView.addSubview(contentView)
        contentView.addSubview(resultTitleLabel)
        contentView.addSubview(resultConceptLabel)
        contentView.addSubview(conceptSupplementLabel)
        contentView.addSubview(scoreView)
        contentView.addSubview(conceptBarGraphView)
        contentView.addSubview(firstTopicLabel)
        contentView.addSubview(secondTopicLabel)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        resultScrollView.translatesAutoresizingMaskIntoConstraints = false
        resultTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        resultConceptLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreView.translatesAutoresizingMaskIntoConstraints = false
        conceptBarGraphView.translatesAutoresizingMaskIntoConstraints = false
        conceptSupplementLabel.translatesAutoresizingMaskIntoConstraints = false
        firstTopicLabel.translatesAutoresizingMaskIntoConstraints = false
        secondTopicLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            resultScrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            resultScrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -64),
            resultScrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 18),
            resultScrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -28),
            
            contentView.topAnchor.constraint(equalTo: resultScrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: resultScrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: resultScrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: resultScrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: resultScrollView.widthAnchor),
            
            resultTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            resultTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            
            scoreView.topAnchor.constraint(equalTo: resultTitleLabel.bottomAnchor, constant: 24),
            scoreView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 18),
            scoreView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            resultConceptLabel.topAnchor.constraint(equalTo: scoreView.bottomAnchor, constant: 32),
            resultConceptLabel.leadingAnchor.constraint(equalTo: resultTitleLabel.leadingAnchor),
            
            conceptBarGraphView.topAnchor.constraint(equalTo: resultConceptLabel.bottomAnchor, constant: 18),
            conceptBarGraphView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            conceptBarGraphView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            conceptSupplementLabel.topAnchor.constraint(equalTo: conceptBarGraphView.bottomAnchor),
            conceptSupplementLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            conceptSupplementLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            conceptSupplementLabel.heightAnchor.constraint(equalToConstant: 24),
            
            firstTopicLabel.topAnchor.constraint(equalTo: conceptSupplementLabel.bottomAnchor, constant: 16),
            firstTopicLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            firstTopicLabel.trailingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -4),
            firstTopicLabel.heightAnchor.constraint(equalToConstant: 70),
            
            secondTopicLabel.topAnchor.constraint(equalTo: conceptSupplementLabel.bottomAnchor, constant: 16),
            secondTopicLabel.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 4),
            secondTopicLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            secondTopicLabel.heightAnchor.constraint(equalToConstant: 70),
            secondTopicLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -60)
        ])
    }
    
    private func setLayoutWithoutBarGraph() {
        
        resultConceptLabel.removeFromSuperview()
        conceptBarHostingController.view.removeFromSuperview()
        
        NSLayoutConstraint.activate([
            conceptSupplementLabel.topAnchor.constraint(equalTo: scoreHostingController.view.bottomAnchor, constant: 32)
        ])
    }
    
    private func resizeConceptBarGarphView() {

        NSLayoutConstraint.deactivate([
            conceptBarHostingController.view.heightAnchor.constraint(greaterThanOrEqualTo: conceptBarHostingController.view.widthAnchor)
        ])
        
        conceptBarHostingController.view.removeConstraints(conceptBarHostingController.view.constraints)
        
        NSLayoutConstraint.activate([
            conceptBarHostingController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            conceptBarHostingController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        
        conceptBarHostingController.view.layoutIfNeeded()
    }
}
