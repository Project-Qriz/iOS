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
        let initEntry: ExamEntryCardCell.State = userInfo.previewTestStatus == .previewCompleted ? .mock : .preview
        let initState = HomeState(
            userName: userInfo.name,
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
            let dDay = calculateDday(from: response.data.examDate)
            let status: ExamStatus = dDay <= 0 ? .expired(detail: detail) : .registered(dDay: dDay, detail: detail)
            let entry: ExamEntryCardCell.State = userInfo.previewTestStatus == .previewCompleted ? .mock : .preview
            return HomeState(
                userName: userInfo.name,
                examStatus: status,
                entryState: entry
            )
        } catch let error as NetworkError {
            if case .clientError(let status, _, _) = error, status == 400 {
                let entry: ExamEntryCardCell.State = userInfo.previewTestStatus == .previewCompleted ? .mock : .preview
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
            let entry: ExamEntryCardCell.State = userInfo.previewTestStatus == .previewCompleted ? .mock : .preview
            updateState { $0 = HomeState(userName: userInfo.name, examStatus: .none, entryState: entry) }
        default:
            outputSubject.send(.showErrorAlert(error.errorMessage))
        }
        logger.error("NetworkError: \(error.description, privacy: .public)")
    }
    
    /// 시험일까지 남은 일수를 계산해주는 메서드입니다.
    private func calculateDday(from dateString: String) -> Int {
        let trimmed = dateString.split(separator: "(").first.map(String.init) ?? dateString
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = "M월 d일"
        guard let mdDate = formatter.date(from: trimmed) else { return Int.min }
        var comps = Calendar.current.dateComponents([.year], from: Date())
        let mdComps = Calendar.current.dateComponents([.month, .day], from: mdDate)
        comps.month = mdComps.month
        comps.day = mdComps.day
        comps.calendar = Calendar.current
        comps.timeZone = TimeZone(identifier: "Asia/Seoul")
        guard let target = comps.date else { return Int.min }
        let today = Calendar.current.startOfDay(for: Date())
        return Calendar.current.dateComponents([.day], from: today, to: target).day ?? Int.min
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
    }
    
    enum Output {
        case updateState(HomeState)
        case showErrorAlert(String)
    }
}

extension HomeViewModel {
    @MainActor
    func reloadExamSchedule() {
        Task { await loadExamSchedule() }
    }
}
