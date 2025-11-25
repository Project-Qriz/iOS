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
    
    weak var delegate: ExamSelectionDelegate?
    private let examScheduleService: ExamScheduleService
    private let outputSubject: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.ksh.qriz", category: "ExamScheduleSelectionViewModel")
    
    private var registeredApplicationId: Int?
    private var registeredUserApplyId: Int?
    
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
                    
                case .examTapped(let id):
                    Task { await self.handleExamTapped(id: id) }
                }
            }
            .store(in: &cancellables)
        
        return outputSubject.eraseToAnyPublisher()
    }
    
    
    @MainActor
    private func loadExamList() async {
        do {
            let response = try await examScheduleService.fetchExamList()
            registeredApplicationId = response.data.registeredApplicationId
            registeredUserApplyId = response.data.registeredUserApplyId
            
            let rows = response.convert()
            outputSubject.send(.loadExamList(rows: rows))
            
        } catch let error as NetworkError {
            outputSubject.send(.showErrorAlert(error.errorMessage))
            logger.error("NetworkError(fetchExamList): \(error.description, privacy: .public)")
            
        } catch {
            outputSubject.send(.showErrorAlert("목록을 불러오지 못했습니다."))
            logger.error("Unhandled error(fetchExamList): \(error.localizedDescription, privacy: .public)")
        }
    }
    
    @MainActor
    private func handleExamTapped(id: Int) async {
        guard id != registeredApplicationId else { return }
        
        do {
            if let userApplyId = registeredUserApplyId {
                _ = try await examScheduleService.updateExamSchedule(
                    userApplyId: userApplyId,
                    newApplyId: id
                )
            } else {
                _ = try await examScheduleService.applyExamSchedule(applyId: id)
            }
            
            await loadExamList()
            delegate?.didUpdateExamSchedule()
            
        } catch let error as NetworkError {
            outputSubject.send(.showErrorAlert(error.errorMessage))
            logger.error("NetworkError(fetchExamDetail): \(error.description, privacy: .public)")
            
        } catch {
            outputSubject.send(.showErrorAlert("시험 정보를 불러오지 못했습니다."))
            logger.error("Unhandled error(fetchExamDetail): \(error.localizedDescription, privacy: .public)")
        }
    }
}

extension ExamScheduleSelectionViewModel {
    enum Input {
        case viewDidLoad
        case examTapped(Int)
    }
    
    enum Output {
        case loadExamList(rows: [ExamRowState])
        case showErrorAlert(String)
    }
}
