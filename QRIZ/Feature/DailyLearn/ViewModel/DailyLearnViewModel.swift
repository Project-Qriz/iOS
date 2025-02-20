//
//  DailyLearnViewModel.swift
//  QRIZ
//
//  Created by ch on 2/16/25.
//

import Foundation
import Combine

final class DailyLearnViewModel {
    
    // MARK: - Input & Output
    enum Input {
        case viewDidLoad(day: Int)
        case testNavigatorButtonClicked
    }
    
    enum Output {
        case fetchSuccess(state: DailyTestState,
                          type: DailyLearnType,
                          score: Int?
        )
        case updateContent(keyConcept1: String,
                           conceptContent1: String,
                           keyConcept2: String, 
                           conceptContent2: String
        )
        case fetchFailed
        case moveToDailyTest(isRetest: Bool)
        case moveToDailyTestResult
    }
    
    // MARK: - Properties
    private var day: Int = -1
    private var state: DailyTestState = .unavailable
    private var type: DailyLearnType = .daily
    private var score: Int? = nil
    private var keyConcept1: String = ""
    private var keyConcept2: String = ""
    private var conceptContent1: String = ""
    private var conceptContent2: String = ""
    
    private let output: PassthroughSubject<Output, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Methods
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .viewDidLoad(let day):
                self.day = day
                fetchData()
            case .testNavigatorButtonClicked:
                handleNavigateAction()
            }
        }
        .store(in: &subscriptions)
        return output.eraseToAnyPublisher()
    }
    
    private func fetchData() {
        // will be replaced to network code && update properties
        output.send(.fetchSuccess(state: .unavailable, type: .daily, score: nil))
        output.send(.updateContent(keyConcept1: "데이터베이스", conceptContent1: "• JOIN은 두 개 이상의 테이블을 연결하여 데이터를 출력하는 것을 의미한다.\n• JOIN은 두 개 이상의 테이블을 연결하여 데이터를 출력하는 것을 의미한다.\n• JOIN은 두 개 이상의 테이블을 연결하여 데이터를 출력하는 것을 의미한다.\n• JOIN은 두 개 이상의 테이블을 연결하여 데이터를 출력하는 것을 의미한다.", keyConcept2: "데이터베이스", conceptContent2: "• JOIN은 두 개 이상의 테이블을 연결하여 데이터를 출력하는 것을 의미한다.\n• JOIN은 두 개 이상의 테이블을 연결하여 데이터를 출력하는 것을 의미한다.\n• JOIN은 두 개 이상의 테이블을 연결하여 데이터를 출력하는 것을 의미한다.\n• JOIN은 두 개 이상의 테이블을 연결하여 데이터를 출력하는 것을 의미한다."))
    }
    
    private func handleNavigateAction() {
        switch state {
        case .unavailable:
            return
        case .zeroAttempt:
            output.send(.moveToDailyTest(isRetest: false))
        case .retestRequired:
            output.send(.moveToDailyTest(isRetest: true))
        case .passed, .failed:
            output.send(.moveToDailyTestResult)
        }
    }
}
