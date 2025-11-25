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
    private let weeklyService: WeeklyRecommendService
    private let userInfo = UserInfoManager.shared
    private let stateSubject: CurrentValueSubject<HomeState, Never>
    private let outputSubject: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.ksh.qriz", category: "HomeViewModel")
    
    // MARK: - Initialize
    
    init(examScheduleService: ExamScheduleService,
         dailyService: DailyService,
         weeklyService: WeeklyRecommendService
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
        self.weeklyService = weeklyService
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
                    
                case .dayHeaderTapped:
                    let state = stateSubject.value
                    let totalDays = state.dailyPlans.count
                    let selectedDay = state.selectedIndex
                    let todayIdx = state.dailyPlans.firstIndex { $0.today }
                    
                    outputSubject.send(.showDaySelectAlert(
                        totalDays: totalDays,
                        selectedDay: selectedDay,
                        todayIndex: todayIdx
                    ))
                    
                case .didConfirmResetPlan:
                    Task { await self.performReset() }
                    
                case .ctaTapped(let dayIndex):
                    let plan = stateSubject.value.dailyPlans[dayIndex]
                    let learnType: DailyLearnType = plan.comprehensiveReviewDay ? .monthly :
                    plan.reviewDay ? .weekly : .daily
                    self.outputSubject.send(.showDaily(day: dayIndex + 1, type: learnType))
                    
                case .weeklyConceptTapped(let index):
                    let concept = stateSubject.value.weeklyConcepts[index]
                    guard let chapter = concept.chapter,
                          let item = concept.conceptItem
                    else { return }
                    
                    self.outputSubject.send(.showConceptPDF(chapter: chapter, item: item)
                    )
                }
            }
            .store(in: &cancellables)
        
        return outputSubject.eraseToAnyPublisher()
    }
    
    @MainActor
    private func loadAllData() async {
        async let examState = makeExamState()
        async let dailyPlans = loadDailyPlans()
        async let weeklyBlock = loadWeeklyRecommend()
        
        do {
            var state = try await examState
            state.dailyPlans = try await dailyPlans
            
            if let weekly = try await weeklyBlock {
                state.recommendationKind = weekly.kind
                state.weeklyConcepts = weekly.concepts
            }
            
            let firstIncomplete = state.dailyPlans.firstIndex(where: { $0.completed == false }) ?? 0
            state.selectedIndex = firstIncomplete
            
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
            outputSubject.send(.showErrorAlert(title: "초기화할 수 없습니다.", description: error.errorMessage))
            logger.error("NetworkError(resetPlan): \(error.description, privacy: .public)")
            
        } catch {
            outputSubject.send(.showErrorAlert(title: "초기화할 수 없습니다."))
            logger.error("Unhandled error(resetPlan): \(error.localizedDescription, privacy: .public)")
        }
    }
    
    private func makeExamState() async throws -> HomeState {
        do {
            let response = try await examScheduleService.fetchAppliedExams()
            let detail = ExamDetail(
                examDateText: response.data.examDate,
                examName: response.data.examName,
                applyPeriod: response.data.period
            )
            let dDay = response.data.examDate.dDay
            let status: ExamStatus = dDay <= 0
            ? .expired(detail: detail)
            : .registered(dDay: dDay, detail: detail)
            
            return HomeState(userName: userInfo.name,
                             examStatus: status,
                             entryState: currentEntryState(),
                             dailyPlans: [],
                             selectedIndex: 0)
            
        } catch let NetworkError.clientError(httpStatus, _, _) where httpStatus == 400 {
            return HomeState(userName: userInfo.name,
                             examStatus: .none,
                             entryState: currentEntryState(),
                             dailyPlans: [],
                             selectedIndex: 0)
        }
    }
    
    private func loadDailyPlans() async throws -> [DailyPlan] {
        let response = try await dailyService.getDailyPlan()
        return response.data ?? []
    }
    
    private func loadWeeklyRecommend() async throws -> (kind: RecommendationKind, concepts: [WeeklyConcept])? {
        let response = try await weeklyService.fetchWeeklyRecommend()
        return response.data.toKindAndConcepts()
    }
    
    private func handle(_ err: Error) {
        if let net = err as? NetworkError {
            outputSubject.send(.showErrorAlert(title: net.errorMessage))
            logger.error("NetworkError: \(net.description, privacy: .public)")
        } else {
            outputSubject.send(.showErrorAlert(title: "잠시 후 다시 시도해 주세요."))
            logger.error("Unhandled: \(err.localizedDescription, privacy: .public)")
        }
    }
    
    private func updateState(_ mutate: (inout HomeState) -> Void) {
        var newState = stateSubject.value
        mutate(&newState)
        stateSubject.send(newState)
        outputSubject.send(.updateState(newState))
    }
    
    private func currentEntryState() -> EntryCardState {
        switch userInfo.previewTestStatus {
        case .previewCompleted, .previewSkipped: .mock
        default: .preview
        }
    }
}

extension HomeViewModel {
    enum Input {
        case viewDidLoad
        case entryTapped
        case daySelected(Int)
        case dayHeaderTapped
        case resetTapped
        case didConfirmResetPlan
        case ctaTapped(day: Int)
        case weeklyConceptTapped(Int)
    }
    
    enum Output {
        case updateState(HomeState)
        case showErrorAlert(title: String, description: String? = nil)
        case navigateToOnboarding
        case navigateToExamList
        case showDaySelectAlert(totalDays: Int, selectedDay: Int, todayIndex: Int?)
        case showResetAlert
        case resetSucceeded(message: String)
        case showDaily(day: Int, type: DailyLearnType)
        case showConceptPDF(chapter: Chapter, item: ConceptItem)
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
