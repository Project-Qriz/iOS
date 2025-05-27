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
    private let stateSubject = CurrentValueSubject<HomeState, Never>(
        .init(examItem: .init(userName: "", kind: .notRegistered),
              entryState: .preview)
    )
    private let outputSubject: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "kr.QRIZ", category: "HomeViewModel")
    
    // MARK: - Initialize
    
    init(examScheduleService: ExamScheduleService) {
        self.examScheduleService = examScheduleService
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
    
    // TODO: - 사용자 정보(userName) API 추후에 연동 필요
    
    @MainActor
    private func loadExamSchedule() async {
        do {
            let item = try await buildExamItem()
            updateState { $0.examItem = item }
            
        } catch let networkError as NetworkError {
            handleNetworkError(networkError)
            
        } catch {
            outputSubject.send(.showErrorAlert("잠시 후 다시 시도해 주세요."))
            logger.error("Unhandled error in loadExamSchedule: \(error.localizedDescription, privacy: .public)")
        }
    }
    
    private func buildExamItem() async throws -> ExamScheduleItem {
        let response = try await examScheduleService.fetchAppliedExams()
        let detail = ExamScheduleItem.Kind.Detail(
            examDateText: response.data.examDate,
            examName:     response.data.examName,
            applyPeriod:  response.data.period
        )
        let dDay = remainingDays(from: response.data.examDate)
        let kind = makeKind(dDay: dDay, detail: detail)
        return ExamScheduleItem(userName: "세훈", kind: kind)
    }
    
    /// D- day 값에 따라 expired를 판별해주는 메서드
    private func makeKind(dDay: Int, detail: ExamScheduleItem.Kind.Detail) -> ExamScheduleItem.Kind {
        return dDay < 0 ? .expired : .registered(dDay: dDay, detail: detail)
    }
    
    private func handleNetworkError(_ error: NetworkError) {
        switch error {
        case .clientError(let status, _, _) where status == 400:
            updateState { $0.examItem = ExamScheduleItem(userName: "세훈", kind: .notRegistered) }
            
        default:
            outputSubject.send(.showErrorAlert(error.errorMessage))
        }
        logger.error("NetworkError: \(error.description, privacy: .public)")
    }
    
    /// 시험일까지 남은 일수를 계산해주는 메서드입니다.
    private func remainingDays(from dateString: String) -> Int {
        let trimmed = dateString.split(separator: "(").first.map(String.init) ?? dateString
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = "M월 d일"
        
        guard
            let mdDate = formatter.date(from: trimmed),
            let comps = Calendar.current.dateComponents([.month, .day], from: mdDate) as DateComponents?
        else { return Int.min }
        
        var targetComps = Calendar.current.dateComponents([.year], from: Date())
        targetComps.month = comps.month
        targetComps.day = comps.day
        targetComps.calendar = Calendar.current
        targetComps.timeZone = TimeZone(identifier: "Asia/Seoul")
        
        guard let target = targetComps.date else { return Int.min }
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
