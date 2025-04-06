//
//  DailyTestViewModel.swift
//  QRIZ
//
//  Created by 이창현 on 4/1/25.
//

import Foundation
import Combine

final class DailyTestViewModel {
    
    // MARK: - Input & Output
    enum Input {
        case viewDidLoad
//        case viewDidAppear
//        case previousButtonClicked
//        case nextButtonClicked
        case cancelButtonClicked
//        case alertSubmitButtonClicked
//        case alertCancelButtonClicked
    }
    
    enum Output {
//        case updateQuestion(question: QuestionData)
//        case updateLastQuestionNum(lastNum: Int)
//        case updateLastQuestionNum(num: Int)
        case updateTime(timeLimit: Int, timeRemaining: Int)
//        case moveToPreviewResult
        case moveToHomeView
//        case submitSuccess
//        case submitFail
//        case cancelSubmit
    }
    
    // MARK: - Properties
    private let output: PassthroughSubject<Output, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Methods
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .viewDidLoad:
                output.send(.updateTime(timeLimit: 10, timeRemaining: 3))
            case .cancelButtonClicked:
                output.send(.moveToHomeView)
//            case .viewDidAppear:
//            case .previousButtonClicked:
//            case .nextButtonClicked:
//            case .escapeButtonClicked:
//            case .alertSubmitButtonClicked:
//            case .alertCancelButtonClicked:
            }
        }
        .store(in: &subscriptions)
        return output.eraseToAnyPublisher()
    }
}
