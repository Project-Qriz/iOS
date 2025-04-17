//
//  PreviewResultViewModel.swift
//  QRIZ
//
//  Created by ch on 12/28/24.
//

import Foundation
import Combine

final class PreviewResultViewModel {
    
    // MARK: - Input & Output
    enum Input {
        case viewDidLoad
        case viewDidAppear
        case toHomeButtonClicked
    }
    
    enum Output {
        case createDataFailed
        case moveToGreetingView
    }
    
    // MARK: - Properties
    var previewScoresData = ResultScoresData()
    var previewConceptsData = PreviewConceptsData()
    
    private let output: PassthroughSubject<Output, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Methods
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .viewDidLoad:
                updateTextData()
                setChartLayout()
            case .viewDidAppear:
                updateScoreAnimationData()
                updateConceptAnimationData()
                
            case .toHomeButtonClicked:
                output.send(.moveToGreetingView)
            }
        }
        .store(in: &subscriptions)
        return output.eraseToAnyPublisher()
    }
    
    private func updateTextData() {
        updateMockTextData()
    }
    
    private func updateScoreAnimationData() {
        updateMockScoreAnimationData()
    }
    
    private func updateConceptAnimationData() {
        updateMockConceptAnimationData()
    }
    
    private func setChartLayout() {
        setMockChartLayout()
    }
    
    // MARK: - Test Methods
    private func updateMockTextData() {
        self.previewScoresData.nickname = "채영"
        self.previewScoresData.expectScore = 58
        
        self.previewConceptsData.firstConcept = "DDL"
        self.previewConceptsData.secondConcept = "조인"
        self.previewConceptsData.totalQuestions = 20
    }
    
    private func updateMockScoreAnimationData() {
        self.previewScoresData.subject1Score = 40
        self.previewScoresData.subject2Score = 20
    }
    
    private func updateMockConceptAnimationData() {
        self.previewConceptsData.incorrectCountDataArr = [
            IncorrectCountData(id: 1, incorrectCount: 5, topic: ["DDL"]),
            IncorrectCountData(id: 2, incorrectCount: 5, topic: ["속성"]),
            IncorrectCountData(id: 3, incorrectCount: 3, topic: ["조인"]),
        ]
    }
    
    private func setMockChartLayout() {
        self.previewConceptsData.numOfTotalConcept = 3
        self.previewConceptsData.initAnimationChart(numOfCharts: 3)
    }
}
