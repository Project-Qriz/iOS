//
//  ExamSummaryViewModel.swift
//  QRIZ
//
//  Created by ch on 5/14/25.
//

import Foundation
import Combine

final class ExamSummaryViewModel {
    
    // MARK: - Input & Output
    enum Input {
        case beginExamButtonClicked
    }
    
    enum Output {
        case moveToExam(examId: Int)
    }
    
    // MARK: - Properties
    private let examId: Int
    
    private let output: PassthroughSubject<Output, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = .init()

    // MARK: - Initializers
    init(examId: Int) {
        self.examId = examId
    }
    
    // MARK: - Methods
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .beginExamButtonClicked:
                output.send(.moveToExam(examId: self.examId))
            }
        }
        .store(in: &subscriptions)
        return output.eraseToAnyPublisher()
    }
}
