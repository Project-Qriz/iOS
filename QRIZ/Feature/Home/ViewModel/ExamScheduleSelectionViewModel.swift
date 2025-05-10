//
//  ExamScheduleSelectionViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 5/2/25.
//

import Foundation
import Combine
import os.log

final class ExamScheduleSelectionViewModel {
    
    // MARK: - Properties
    
    private let examScheduleService: ExamScheduleService
    private let outputSubject: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "kr.QRIZ", category: "ExamScheduleSelectionViewModel")
    
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
                    Task { await self.loadExamList() }
                }
            }
            .store(in: &cancellables)
        
        return outputSubject.eraseToAnyPublisher()
    }
    
    
    @MainActor
    private func loadExamList() async {
        do {
            let rows = try await examScheduleService.fetchExamList().convert()
            outputSubject.send(.loadExamList(rows: rows))
            
        } catch let error as NetworkError {
            outputSubject.send(.showErrorAlert(error.errorMessage))
            logger.error("NetworkError(fetchExamList): \(error.description, privacy: .public)")
            
        } catch {
            outputSubject.send(.showErrorAlert("목록을 불러오지 못했습니다."))
            logger.error("Unhandled error(fetchExamList): \(error.localizedDescription, privacy: .public)")
        }
    }
}

extension ExamScheduleSelectionViewModel {
    enum Input {
        case viewDidLoad
    }
    
    enum Output {
        case loadExamList(rows: [ExamRowState])
        case showErrorAlert(String)
    }
}
