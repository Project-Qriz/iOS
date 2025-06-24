//
//  HomeViewModel.swift
//  QRIZ
//
//  Created by KSH on 12/11/24.
//

import Foundation
import Combine
import os.log

final class HomeViewModel {
    
    // MARK: - Properties
    
    private let examScheduleService: ExamScheduleService
    private let userInfo = UserInfoManager.shared
    private let stateSubject: CurrentValueSubject<HomeState, Never>
    private let outputSubject: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "kr.QRIZ", category: "HomeViewModel")
    
    // MARK: - Initialize
    
    init(examScheduleService: ExamScheduleService) {
        let name = UserInfoManager.shared.name
        let previewStatus = UserInfoManager.shared.previewTestStatus
        let initEntry: EntryCardState = {
            switch previewStatus {
            case .previewCompleted, .previewSkipped:
                return .mock
            default:
                return .preview
            }
        }()
        
        let initState = HomeState(
            userName: name,
            examStatus: .none,
            entryState: initEntry
        )
        self.examScheduleService = examScheduleService
        self.stateSubject = .init(initState)
    }
    
    // MARK: - Functions
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .viewDidLoad:
                    Task { await self.loadExamSchedule() }
                case .entryTapped:
                    let entryState = self.stateSubject.value.entryState
                    
                    switch entryState {
                    case .preview:
                        self.outputSubject.send(.navigateToOnboarding)
                    case .mock:
                        self.outputSubject.send(.navigateToExamList)
                    }
                }
            }
            .store(in: &cancellables)
        
        return outputSubject.eraseToAnyPublisher()
    }
    
    @MainActor
    private func loadExamSchedule() async {
        do {
            let state = try await makeState()
            updateState { $0 = state }
            
        } catch let networkError as NetworkError {
            handleNetworkError(networkError)
            
        } catch {
            outputSubject.send(.showErrorAlert("잠시 후 다시 시도해 주세요."))
            logger.error("Unhandled error in loadExamSchedule: \(error.localizedDescription, privacy: .public)")
        }
    }
    
    private func makeState() async throws -> HomeState {
        do {
            let response = try await examScheduleService.fetchAppliedExams()
            let detail = ExamDetail(
                examDateText: response.data.examDate,
                examName: response.data.examName,
                applyPeriod: response.data.period
            )
            let dDay = response.data.examDate.dDay
            let status: ExamStatus = dDay <= 0 ? .expired(detail: detail) : .registered(dDay: dDay, detail: detail)
            let entry: EntryCardState = {
                switch userInfo.previewTestStatus {
                case .previewCompleted, .previewSkipped:
                    return .mock
                default:
                    return .preview
                }
            }()
            return HomeState(
                userName: userInfo.name,
                examStatus: status,
                entryState: entry
            )
        } catch let error as NetworkError {
            if case .clientError(let status, _, _) = error, status == 400 {
                let entry: EntryCardState = userInfo.previewTestStatus == .previewCompleted ? .mock : .preview
                return HomeState(
                    userName: userInfo.name,
                    examStatus: .none,
                    entryState: entry
                )
            }
            throw error
        }
    }
    
    private func handleNetworkError(_ error: NetworkError) {
        switch error {
        case .clientError(let status, _, _) where status == 400:
            let entry: EntryCardState = userInfo.previewTestStatus == .previewCompleted ? .mock : .preview
            updateState { $0 = HomeState(userName: userInfo.name, examStatus: .none, entryState: entry) }
        default:
            outputSubject.send(.showErrorAlert(error.errorMessage))
        }
        logger.error("NetworkError: \(error.description, privacy: .public)")
    }
    
    private func updateState(_ mutate: (inout HomeState) -> Void) {
        var newState = stateSubject.value
        mutate(&newState)
        stateSubject.send(newState)
        outputSubject.send(.updateState(newState))
    }
}

extension HomeViewModel {
    enum Input {
        case viewDidLoad
        case entryTapped
    }
    
    enum Output {
        case updateState(HomeState)
        case showErrorAlert(String)
        case navigateToOnboarding
        case navigateToExamList
    }
}

extension HomeViewModel {
    @MainActor
    func reloadExamSchedule() {
        Task { await loadExamSchedule() }
    }
    
    @MainActor
    func reloadUserState() {
        updateState { state in
            print(state)
            switch userInfo.previewTestStatus {
            case .previewCompleted, .previewSkipped:
                state.entryState = .mock
            default:
                state.entryState = .preview
            }
        }
    }
}
