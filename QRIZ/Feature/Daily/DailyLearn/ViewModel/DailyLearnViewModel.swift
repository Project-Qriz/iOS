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
        case toConceptClicked(conceptIdx: Int)
        case alertMoveClicked
        case alertCancelClicked
    }
    
    enum Output {
        case fetchSuccess(state: DailyTestState,
                          type: DailyLearnType,
                          score: Double?
        )
        case updateContent(conceptArr: [(Int, String)])
        case fetchFailed(isServerError: Bool)
        case moveToDailyTest(type: DailyLearnType, day: Int)
        case showRetestAlert
        case moveToDailyTestResult(type: DailyLearnType, day: Int)
        case moveToConcept(conceptIdx: Int)
        case dismissAlert
    }
    
    // MARK: - Properties
    private let day: Int
    private let type: DailyLearnType
    private var state: DailyTestState = .unavailable
    private var score: Double? = nil
    private var conceptArr: [(Int, String)] = []
    
    private let output: PassthroughSubject<Output, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    private let dailyService: DailyService
    
    // MARK: - Intiailizer
    init(day: Int, type: DailyLearnType, dailyService: DailyService) {
        self.day = day
        self.type = type
        self.dailyService = dailyService
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
            case .toConceptClicked(let conceptIdx):
                output.send(.moveToConcept(conceptIdx: conceptIdx))
            case .alertMoveClicked:
                output.send(.dismissAlert)
                output.send(.moveToDailyTest(type: type, day: day))
            case .alertCancelClicked:
                output.send(.dismissAlert)
            }
        }
        .store(in: &subscriptions)
        return output.eraseToAnyPublisher()
    }
    
    private func fetchData() {
        Task {
            do {
                let response = try await dailyService.getDailyDetailAndStatus(dayNumber: day)
                let status = response.data.status

                setTestState(attemptCount: status.attemptCount,
                             passed: status.passed,
                             retestEligible: status.retestEligible,
                             available: status.available)
                setTestScore(attemptCount: status.attemptCount, score: status.totalScore)
                response.data.skills.forEach {
                    conceptArr.append(($0.id, $0.description))
                }
                output.send(.fetchSuccess(state: state, type: type, score: score))
                output.send(.updateContent(conceptArr: conceptArr))
            } catch NetworkError.serverError {
                output.send(.fetchFailed(isServerError: true))
            } catch {
                output.send(.fetchFailed(isServerError: false))
            }
        }
    }
    
    private func setTestState(attemptCount: Int, passed: Bool, retestEligible: Bool, available: Bool) {
        if !available {
            state = .unavailable
            return
        }
        if passed {
            state = .passed
            return
        }
        if retestEligible {
            state = .retestRequired
            return
        }
        if attemptCount == 0 {
            state = .zeroAttempt
            return
        }
        state = .failed
    }
    
    private func setTestScore(attemptCount: Int, score: CGFloat) {
        self.score = attemptCount > 0 ? score : nil
    }
    
    private func handleNavigateAction() {
        switch state {
        case .unavailable:
            return
        case .zeroAttempt:
            output.send(.moveToDailyTest(type: type, day: day))
        case .retestRequired:
            output.send(.showRetestAlert)
        case .passed, .failed:
            output.send(.moveToDailyTestResult(type: type, day: day))
        }
    }
}
