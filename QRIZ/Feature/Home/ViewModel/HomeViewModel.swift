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
    private let dailyService: DailyService
    private let userInfo = UserInfoManager.shared
    private let stateSubject: CurrentValueSubject<HomeState, Never>
    private let outputSubject: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "kr.QRIZ", category: "HomeViewModel")
    
    // MARK: - Initialize
    
    init(examScheduleService: ExamScheduleService,
         dailyService: DailyService
    ) {
        let name = UserInfoManager.shared.name
        let previewStatus = UserInfoManager.shared.previewTestStatus
        let entry: EntryCardState = {
            switch previewStatus {
            case .previewCompleted, .previewSkipped:
                return .mock
            default:
                return .preview
            }
        }()
        
        let initState = HomeState(userName: name,
                                  examStatus: .none,
                                  entryState: entry,
                                  dailyPlans: [],
                                  selectedIndex: 0
        )
        self.examScheduleService = examScheduleService
        self.dailyService = dailyService
        self.stateSubject = .init(initState)
    }
    
    // MARK: - Functions
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .viewDidLoad:
                    Task { await self.loadAllData() }
                    
                case .entryTapped:
                    let entryState = self.stateSubject.value.entryState
                    
                    switch entryState {
                    case .preview:
                        self.outputSubject.send(.navigateToOnboarding)
                    case .mock:
                        self.outputSubject.send(.navigateToExamList)
                    }
                    
                case .resetTapped:
                    self.outputSubject.send(.showResetAlert)
                    
                case .daySelected(let index):
                    self.updateState { $0.selectedIndex = index }
                    
                case .didConfirmResetPlan:
                    Task { await self.performReset() }
                }
            }
            .store(in: &cancellables)
        
        return outputSubject.eraseToAnyPublisher()
    }
    
    @MainActor
    private func loadAllData() async {
        async let examState = makeExamState()
        async let dailyPlans = loadDailyPlans()

        do {
            var state = try await examState
            state.dailyPlans = try await dailyPlans
            state.selectedIndex = 0

            updateState { $0 = state }

        } catch {
            handle(error)
        }
    }
    
    @MainActor
    private func performReset() async {
        do {
            let response = try await dailyService.resetPlan()
            outputSubject.send(.resetSucceeded(message: response.msg))
            
        } catch let error as NetworkError  {
            outputSubject.send(.showErrorAlert(error.errorMessage))
            logger.error("NetworkError(resetPlan): \(error.description, privacy: .public)")
            
        } catch {
            outputSubject.send(.showErrorAlert("플랜 초기화에 실패했습니다."))
            logger.error("Unhandled error(resetPlan): \(error.localizedDescription, privacy: .public)")
        }
    }
    
    private func makeExamState() async throws -> HomeState {
        let response = try await examScheduleService.fetchAppliedExams()
        let detail = ExamDetail(examDateText: response.data.examDate,
                                  examName: response.data.examName,
                                  applyPeriod: response.data.period)
        let dDay = response.data.examDate.dDay
        let status: ExamStatus = dDay <= 0 ? .expired(detail: detail) : .registered(dDay: dDay, detail: detail)

        let entry: EntryCardState = {
            switch userInfo.previewTestStatus {
            case .previewCompleted, .previewSkipped: return .mock
            default: return .preview
            }
        }()

        return HomeState(userName: userInfo.name,
                         examStatus: status,
                         entryState: entry,
                         dailyPlans: [],
                         selectedIndex: 0)
    }
    
    private func loadDailyPlans() async throws -> [DailyPlan] {
        let response = try await dailyService.getDailyPlan()
        return response.data
    }
    
    private func handle(_ err: Error) {
        if let net = err as? NetworkError {
            outputSubject.send(.showErrorAlert(net.errorMessage))
            logger.error("NetworkError: \(net.description, privacy: .public)")
        } else {
            outputSubject.send(.showErrorAlert("잠시 후 다시 시도해 주세요."))
            logger.error("Unhandled: \(err.localizedDescription, privacy: .public)")
        }
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
        case daySelected(Int)
        case resetTapped
        case didConfirmResetPlan
        
    }
    
    enum Output {
        case updateState(HomeState)
        case showErrorAlert(String)
        case navigateToOnboarding
        case navigateToExamList
        case showResetAlert
        case resetSucceeded(message: String)
    }
}

extension HomeViewModel {
    @MainActor
    func reloadExamSchedule() {
        Task { await loadAllData() }
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
