//
//  DailyResultViewModel.swift
//  QRIZ
//
//  Created by 이창현 on 4/1/25.
//

import Foundation
import Combine

final  class DailyResultViewModel {
    
    // MARK: - Input & Output
    enum Input {
        
    }
    
    enum Output {
        
    }
    
    // MARK: - Properties
    private var dailyTestType: DailyLearnType
    
    private let output: PassthroughSubject<Output, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Initializers
    init(dailyTestType: DailyLearnType) {
        self.dailyTestType = dailyTestType
    }
    
    // MARK: - Methods
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            guard let self = self else { return }
            switch event {
            default:
                break
            }
        }
        .store(in: &subscriptions)
        return output.eraseToAnyPublisher()
    }
}
