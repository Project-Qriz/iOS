//
//  DailyLearnViewModel.swift
//  QRIZ
//
//  Created by ch on 2/16/25.
//

import Foundation
import Combine
import QRIZUtils
import Network

final class DailyLearnViewModel {

    // MARK: - Enums

    private typealias StatusInfo = DailyDetailAndStatusResponse.DataInfo.StatusInfo

    enum Input {
        case viewDidLoad
        case testNavigatorButtonClicked
        case toConceptClicked(conceptIdx: Int)
        case alertMoveClicked
        case alertCancelClicked
        case backButtonClicked
    }

    enum Output {
        case fetchSuccess(state: DailyTestState, type: DailyLearnType, score: Double?)
        case updateContent(concepts: [(Int, String)])
        case fetchFailed(isServerError: Bool)
        case moveToDailyTest
        case showRetestAlert
        case moveToDailyTestResult
        case moveToConcept(chapter: Chapter, conceptItem: ConceptItem)
        case dismissAlert
        case moveToHome
    }

    // MARK: - Properties

    private let day: Int
    private let type: DailyLearnType
    private var state: DailyTestState = .unavailable
    private var score: Double?
    private var concepts: [(Int, String)] = []

    private let output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()

    private let dailyService: DailyService

    // MARK: - Initialization

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
                output.send(.moveToConcept(
                    chapter: SurveyCheckList.getChapter(conceptIdx - 1),
                    conceptItem: SurveyCheckList.getConceptItem(conceptIdx - 1)
                ))
            case .alertMoveClicked:
                output.send(.dismissAlert)
                output.send(.moveToDailyTest)
            case .alertCancelClicked:
                output.send(.dismissAlert)
            case .backButtonClicked:
                output.send(.moveToHome)
            }
        }
        .store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }

    private func fetchData() {
        Task { [weak self] in
            guard let self = self else { return }
            do {
                let response = try await dailyService.getDailyDetailAndStatus(dayNumber: day)
                let status = response.data.status

                setTestState(from: status)
                setTestScore(from: status)
                concepts = response.data.skills.map { ($0.id, $0.description) }

                output.send(.fetchSuccess(state: state, type: type, score: score))
                output.send(.updateContent(concepts: concepts))
            } catch NetworkError.serverError(_) {
                output.send(.fetchFailed(isServerError: true))
            } catch {
                output.send(.fetchFailed(isServerError: false))
            }
        }
    }

    private func setTestState(from status: StatusInfo) {
        if !status.available {
            state = .unavailable
            return
        }
        if status.passed {
            state = .passed
            return
        }
        if status.retestEligible {
            state = .retestRequired
            return
        }
        state = status.attemptCount == 0 ? .zeroAttempt : .failed
    }

    private func setTestScore(from status: StatusInfo) {
        score = status.attemptCount > 0 ? status.totalScore : nil
    }

    private func handleNavigateAction() {
        switch state {
        case .unavailable:
            return
        case .zeroAttempt:
            output.send(.moveToDailyTest)
        case .retestRequired:
            output.send(.showRetestAlert)
        case .passed, .failed:
            output.send(.moveToDailyTestResult)
        }
    }

    func reloadData() {
        fetchData()
    }
}
