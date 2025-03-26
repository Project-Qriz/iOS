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
        case viewDidLoad
        case testNavigatorButtonClicked
    }
    
    enum Output {
        case fetchSuccess(state: DailyTestState,
                          type: DailyLearnType,
                          score: Int?
        )
        case updateContent(conceptArr: [(String, String)])
        case fetchFailed
        case moveToDailyTest(isRetest: Bool)
        case moveToDailyTestResult
    }
    
    // MARK: - Properties
    private var day: Int
    private var state: DailyTestState = .unavailable
    private var type: DailyLearnType = .daily
    private var score: Int? = nil
    
    private let output: PassthroughSubject<Output, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Intiailizer
    init(day: Int) {
        self.day = day
    }
    
    // MARK: - Methods
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .viewDidLoad:
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
        output.send(.fetchSuccess(state: .retestRequired, type: .daily, score: 30))
        output.send(.updateContent(conceptArr: [
            ("데이터 모델의 이해", "JOIN은 두 개 이상의 테이블을 연결하여 데이터를 출력하는 것을 의미한다."),
            ("엔터티", "JOIN은 두 개 이상의 테이블을 연결하여 데이터를 출력하는 것을 의미한다.")
            ]))
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
