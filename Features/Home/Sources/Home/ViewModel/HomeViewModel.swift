//
//  HomeViewModel.swift
//  QRIZ
//
//  Created by KSH on 12/11/24.
//

import Foundation
import Combine
import os.log
import QRIZUtils
import Network

@MainActor
final class HomeViewModel {
    
    // MARK: - Properties
    
    private let examScheduleService: ExamScheduleService
    private let dailyService: DailyService
    private let weeklyService: WeeklyRecommendService
    private let userInfo = UserInfoManager.shared
    private let stateSubject: CurrentValueSubject<HomeState, Never>
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger.make(category: "HomeViewModel")
    
    // MARK: - Initialization

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

    // MARK: - Methods

    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink { [weak self] event in
                guard let self else { return }
                switch event {
                case .viewDidLoad:
                    Task { [self] in await self.loadAllData() }

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
                    let state = self.stateSubject.value
                    let totalDays = state.dailyPlans.count
                    let selectedDay = state.selectedIndex
                    let todayIdx = state.dailyPlans.firstIndex { $0.today }

                    self.outputSubject.send(.showDaySelectAlert(
                        totalDays: totalDays,
                        selectedDay: selectedDay,
                        todayIndex: todayIdx
                    ))

                case .didConfirmResetPlan:
                    Task { [self] in await self.performReset() }

                case .ctaTapped(let dayIndex):
                    let plan = self.stateSubject.value.dailyPlans[dayIndex]
                    let learnType: DailyLearnType
                    if plan.comprehensiveReviewDay { learnType = .monthly }
                    else if plan.reviewDay { learnType = .weekly }
                    else { learnType = .daily }
                    self.outputSubject.send(.showDaily(day: dayIndex + 1, type: learnType))

                case .weeklyConceptTapped(let index):
                    let concept = self.stateSubject.value.weeklyConcepts[index]
                    guard let chapter = concept.chapter,
                          let item = concept.conceptItem
                    else { return }

                    self.outputSubject.send(.showConceptPDF(chapter: chapter, item: item))
                }
            }
            .store(in: &cancellables)
        
        return outputSubject.eraseToAnyPublisher()
    }
    
    private func loadAllData() async {
        async let examState = makeExamState()
        async let dailyPlans = loadDailyPlans()
        async let weeklyBlock = loadWeeklyRecommend()
        
        do {
            var state = try await examState
            state.dailyPlans = try await dailyPlans

            do {
                if let weekly = try await weeklyBlock {
                    state.recommendationKind = weekly.kind
                    state.weeklyConcepts = weekly.concepts
                }
            } catch {
                logger.error("weekly 조회 실패: \(error.localizedDescription, privacy: .public)")
            }

            let firstIncomplete = state.dailyPlans.firstIndex(where: { !$0.completed }) ?? 0
            state.selectedIndex = firstIncomplete

            updateState { $0 = state }

        } catch {
            handle(error)
        }
    }
    
    private func performReset() async {
        do {
            let response = try await dailyService.resetPlan()
            outputSubject.send(.resetSucceeded(message: response.msg))
            
        } catch let error as NetworkError {
            outputSubject.send(.showErrorAlert(title: "초기화할 수 없습니다.", description: error.errorMessage))
            logger.error("NetworkError(resetPlan): \(error.debugDescription, privacy: .public)")
            
        } catch {
            outputSubject.send(.showErrorAlert(title: "초기화할 수 없습니다."))
            logger.error("Unhandled error(resetPlan): \(error.localizedDescription, privacy: .public)")
        }
    }
    
    private func makeExamState() async throws -> HomeState {
        // 400: 시험 미등록 상태 → 정상 케이스로 처리. 그 외 에러는 rethrow → loadAllData에서 handle
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
    
    private func loadDailyPlans() async throws -> [DailyPlanEntity] {
        let response = try await dailyService.getDailyPlan()
        return response.data?.map { $0.toEntity() } ?? []
    }
    
    private func loadWeeklyRecommend() async throws -> (kind: RecommendationKind, concepts: [WeeklyConcept])? {
        let response = try await weeklyService.fetchWeeklyRecommend()
        return response.data.toKindAndConcepts()
    }
    
    private func handle(_ err: Error) {
        if let net = err as? NetworkError {
            outputSubject.send(.showErrorAlert(title: net.errorMessage))
            logger.error("NetworkError: \(net.debugDescription, privacy: .public)")
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

// MARK: - Internal

extension HomeViewModel {
    func reloadExamSchedule() {
        Task { [weak self] in await self?.loadAllData() }
    }

    func reloadUserState() {
        updateState { state in
            switch userInfo.previewTestStatus {
            case .previewCompleted, .previewSkipped:
                state.entryState = .mock
            default:
                state.entryState = .preview
            }
        }
    }
}
