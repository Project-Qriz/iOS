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
    
    private var resultTitleLabel = PreviewResultTitleLabel(isTitleLabel: true)
    private var resultConceptLabel = PreviewResultTitleLabel(isTitleLabel: false)
    private var scoreCircularChartHostingController: ScoreCircularChartHostingController!
    private var conceptBarHostingController: ConceptBarGraphHostingController!
    private let resultScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .customBlue50
        return scrollView
    }()
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .customBlue50
        return view
    }()
    private var conceptSupplementLabel: UILabel = {
        let label = UILabel()
        label.text = "보충하면 좋은 개념 top2"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .coolNeutral500
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    private var firstTopicLabel = SingleSupplementConceptView()
    private var secondTopicLabel = SingleSupplementConceptView()
    private var moveToHomeButton = OnboardingButton("홈으로 가기")
    
    private var viewModel = PreviewResultViewModel()
    private let input: PassthroughSubject<PreviewResultViewModel.Input, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .customBlue50
        setNavigationItems()
        bind()
        addViews()
        setButtonAction()
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
                case .loadData(let nickname, let firstConcept, let secondConcept):
                    setNicknameToLabel(nickname: nickname)
                    setConceptsToSupplementLabel(firstConcept: firstConcept, secondConcept: secondConcept)
                case .createDataFailed:
                    print("create Data Failed : PreviewResultViewController")
                    //
                case .moveToGreetingView:
                    // coordinator role
                    navigationController?.pushViewController(GreetingViewController(), animated: true)
                case .removeConceptBarGraphView:
                    setLayoutWithoutBarGraph()
                }
            }
            .store(in: &subscriptions)
    }
    
    private func setNavigationItems() {
        self.navigationItem.title = "시험결과"
    }
    
    private func setButtonAction() {
        moveToHomeButton.addAction(UIAction(handler: { [weak self] _ in
            guard let self = self else { return }
            self.input.send(.toHomeButtonClicked)
        }), for: .touchUpInside)
    }
    
    private func setNicknameToLabel(nickname: String) {
        resultTitleLabel.setLabelText(nickname: nickname, isTitleLabel: true)
        resultConceptLabel.setLabelText(nickname: nickname, isTitleLabel: false)
    }
    
    private func setConceptsToSupplementLabel (firstConcept: String, secondConcept: String) {
        firstTopicLabel.setConceptLabelText(topic: firstConcept)
        secondTopicLabel.setConceptLabelText(topic: secondConcept)
    }
    
    private func loadScoreCircularChartView() -> UIView {
        scoreCircularChartHostingController = ScoreCircularChartHostingController(rootView: ScoreCircularChartView(previewScoresData: self.viewModel.previewScoresData))
        self.addChild(scoreCircularChartHostingController)
        scoreCircularChartHostingController.didMove(toParent: self)
        let scoreCircularCharView = scoreCircularChartHostingController.view ?? UIView(frame: .zero)
        scoreCircularCharView.backgroundColor = .white
        scoreCircularCharView.layer.cornerRadius = 16
        return scoreCircularCharView
    }
    
    private func loadConceptBarGraphView() -> UIView {
        conceptBarHostingController = ConceptBarGraphHostingController(rootView: ConceptBarGraphView(previewConceptsData: self.viewModel.previewConceptsData))
        self.addChild(conceptBarHostingController)
        conceptBarHostingController.didMove(toParent: self)
        let conceptBarGraphView = conceptBarHostingController.view ?? UIView(frame: .zero)
        conceptBarGraphView.backgroundColor = .white
        conceptBarGraphView.layer.cornerRadius = 16
        return conceptBarGraphView
    }
    
    private func addViews() { // shadow should be added!
        
        let scoreCircularChartView = loadScoreCircularChartView()
        let conceptBarGraphView = loadConceptBarGraphView()
        
        self.view.addSubview(resultScrollView)
        self.view.addSubview(moveToHomeButton)
        resultScrollView.addSubview(contentView)
        contentView.addSubview(resultTitleLabel)
        contentView.addSubview(resultConceptLabel)
        contentView.addSubview(conceptSupplementLabel)
        contentView.addSubview(scoreCircularChartView)
        contentView.addSubview(conceptBarGraphView)
        contentView.addSubview(firstTopicLabel)
        contentView.addSubview(secondTopicLabel)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        moveToHomeButton.translatesAutoresizingMaskIntoConstraints = false
        resultScrollView.translatesAutoresizingMaskIntoConstraints = false
        resultTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        resultConceptLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreCircularChartView.translatesAutoresizingMaskIntoConstraints = false
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
            resultTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            resultTitleLabel.heightAnchor.constraint(equalToConstant: 64),
            scoreCircularChartView.topAnchor.constraint(equalTo: resultTitleLabel.bottomAnchor, constant: 12),
            scoreCircularChartView.leadingAnchor.constraint(equalTo: resultTitleLabel.leadingAnchor),
            scoreCircularChartView.trailingAnchor.constraint(equalTo: resultTitleLabel.trailingAnchor),
            scoreCircularChartView.heightAnchor.constraint(lessThanOrEqualTo: scoreCircularChartView.widthAnchor),
            resultConceptLabel.topAnchor.constraint(equalTo: scoreCircularChartHostingController.view.bottomAnchor, constant: 32),
            resultConceptLabel.leadingAnchor.constraint(equalTo: resultTitleLabel.leadingAnchor),
            resultConceptLabel.trailingAnchor.constraint(equalTo: resultTitleLabel.trailingAnchor),
            resultConceptLabel.heightAnchor.constraint(equalToConstant: 64),
            conceptBarGraphView.topAnchor.constraint(equalTo: resultConceptLabel.bottomAnchor, constant: 12),
            conceptBarGraphView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            conceptBarGraphView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            conceptBarGraphView.heightAnchor.constraint(greaterThanOrEqualTo: conceptBarGraphView.widthAnchor),
            conceptSupplementLabel.topAnchor.constraint(equalTo: conceptBarGraphView.bottomAnchor, constant: 16),
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
            secondTopicLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -60),
            moveToHomeButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            moveToHomeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            moveToHomeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            moveToHomeButton.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        self.view.bringSubviewToFront(moveToHomeButton)
    }
    
    func setLayoutWithoutBarGraph() {
        
        resultConceptLabel.removeFromSuperview()
        conceptBarHostingController.view.removeFromSuperview()
        
        NSLayoutConstraint.activate([
            conceptSupplementLabel.topAnchor.constraint(equalTo: scoreCircularChartHostingController.view.bottomAnchor, constant: 32)
        ])
    }
}
