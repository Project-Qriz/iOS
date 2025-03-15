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
    var previewScoresData = PreviewScoresData()
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
                setAnimationData()
            case .viewDidAppear:
                updateScoreData()
                updateConceptData()
                
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
    
    private func updateScoreData() {
        updateMockScoreData()
    }
    
    private func updateConceptData() {
        updateMockConceptData()
    }
    
    private func setAnimationData() {
        setMockAnimationData()
    }
    
    private func updateMockTextData() {
        self.previewScoresData.nickname = "채영"
        self.previewScoresData.expectScore = 58
        
        self.previewConceptsData.firstConcept = "DDL"
        self.previewConceptsData.secondConcept = "조인"
    }
    
    private func updateMockScoreData() {
        self.previewScoresData.subject1Score = 40
        self.previewScoresData.subject2Score = 20
        self.previewConceptsData.totalQuestions = 20
    }
    
    private func updateMockConceptData() {
        self.previewConceptsData.incorrectCountDataArr = [
            IncorrectCountData(id: 1, incorrectCount: 5, topic: ["DDL", "속성", "식별자"]),
            IncorrectCountData(id: 2, incorrectCount: 3, topic: ["조인"]),
            IncorrectCountData(id: 3, incorrectCount: 1, topic: ["모델이 표현하는 트랜잭션의 이해"]),
            IncorrectCountData(id: 4, incorrectCount: 1, topic: ["test"])
        ]
    }
    
    private func setMockAnimationData() {
        self.previewConceptsData.animationHandler(numOfData: 4)
    }
}
