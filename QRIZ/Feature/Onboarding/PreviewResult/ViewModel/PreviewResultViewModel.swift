//
//  PreviewResultViewModel.swift
//  QRIZ
//
//  Created by ch on 12/28/24.
//

import Foundation
import Combine

final class PreviewResultViewModel {
    
    enum Input {
        case viewDidLoad
        case viewDidAppear
        case toHomeButtonClicked
    }
    
    enum Output {
        case loadData(nickname: String, firstConcept: String, secondConcept: String)
        case createDataFailed
        case moveToGreetingView
        case removeConceptBarGraphView
    }
    
    var previewScoresData = PreviewScoresData()
    var previewConceptsData = PreviewConceptsData()

    private var nickname: String = "채영" // temp value
    private var firstConcept: String = "DDL" // temp value
    private var secondConcept: String = "조인" // temp value

    private let output: PassthroughSubject<Output, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .viewDidLoad:
                // fetch Data
                output.send(.loadData(nickname: nickname, firstConcept: firstConcept, secondConcept: secondConcept))
            case .viewDidAppear:
                // renew ObservableObject data for SwiftUI View, below are sample datas, should make below to method
                self.previewScoresData.subject1Score = 0.4
                self.previewScoresData.subject2Score = 0.2
                self.previewScoresData.expectScore = 60
                
                self.previewConceptsData.totalQuestions = 20
                self.previewConceptsData.incorrectCountDataArr = [
                    IncorrectCountData(id: 1, topic: "DDL", incorrectCount: 5),
                    IncorrectCountData(id: 2, topic: "조인", incorrectCount: 3),
                    IncorrectCountData(id: 3, topic: "모델이 표현하는 트랜잭션의 이해", incorrectCount: 1),
                    IncorrectCountData(id: 4)
                ]
                
                if self.previewScoresData.expectScore == 100 {
                    output.send(.removeConceptBarGraphView)
                }

            case .toHomeButtonClicked:
                output.send(.moveToGreetingView)
            }
        }
        .store(in: &subscriptions)
        return output.eraseToAnyPublisher()
    }
}
