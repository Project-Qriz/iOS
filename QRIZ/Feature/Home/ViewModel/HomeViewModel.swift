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
    
    @MainActor
    private func loadExamSchedule() async {
        do {
            let response = try await examScheduleService.fetchAppliedExams()
            let data = response.data
            
            let detail = ExamScheduleItem.Kind.Detail(
                examDateText: data.examDate,
                examName: data.examName,
                applyPeriod: data.period
            )
            
            let dDay = calcDDay(from: data.examDate)
            
            let item = ExamScheduleItem(userName: "세훈", kind: .registered(dDay: dDay, detail: detail))
            
            outputSubject.send(.showRegistered(item: item))
            
        } catch let networkError as NetworkError {
            handleNetworkError(networkError)
        } catch {
            outputSubject.send(.showErrorAlert("잠시 후 다시 시도해 주세요."))
            logger.error("Unhandled error in loadExamSchedule: \(error.localizedDescription, privacy: .public)")
        }
    }
    
    func calcDDay(from dateString: String) -> Int {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = "M월 d일(EEE)"
        
        guard let examDate = formatter.date(from: dateString) else { return 0 }
        let today  = Calendar.current.startOfDay(for: Date())
        let target = Calendar.current.startOfDay(for: examDate)
        return Calendar.current.dateComponents([.day], from: today, to: target).day ?? 0
    }
    
    private func handleNetworkError(_ error: NetworkError) {
        switch error {
        case .clientError(let statusCode, _, let message):
            if statusCode == 400 {
                outputSubject.send(.showNotRegistered(user: "김세훈"))
            } else {
                outputSubject.send(.showErrorAlert(message))
            }
        default:
            outputSubject.send(.showErrorAlert(error.errorMessage))
        }
        logger.error("NetworkError in loadExamSchedule: \(error.description, privacy: .public)")
    }
}

extension HomeViewModel {
    enum Input {
        case viewDidLoad
    }
    
    enum Output {
        case showNotRegistered(user: String)
        case showExpired(user: String)
        case showRegistered(item: ExamScheduleItem)
        case showErrorAlert(String)
    }
}
