//
//  DailyResultDetailViewModel.swift
//  QRIZ
//
//  Created by 이창현 on 4/19/25.
//

import Foundation
import Combine

final class DailyResultDetailViewModel {
    
    // MARK: - Input & Output
    enum Input {
        case backButtonClicked
    }
    
    enum Output {
        case moveToDailyResult
    }
    
    // MARK: - Intializers
    init(resultDetailData: ResultDetailData) {
        self.resultDetailData = resultDetailData
    }
    
    // MARK: - Properties
    var resultDetailData: ResultDetailData
    var resultScoresData: ResultScoresData = .init()
    
    private let output: PassthroughSubject<Output, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Methods
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .backButtonClicked:
                output.send(.moveToDailyResult)
            }
        }
        .store(in: &subscriptions)
        return output.eraseToAnyPublisher()
    }
}
