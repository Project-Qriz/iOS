//
//  ExamScheduleSelectionViewModel.swift
//  QRIZ
//
//  Created by 김세훈 on 5/2/25.
//

import Foundation
import Combine
import os.log
import QRIZUtils
import Network

@MainActor
final class ExamScheduleSelectionViewModel {

    // MARK: - Properties

    weak var delegate: ExamSelectionDelegate?
    private let examScheduleService: ExamScheduleService
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger.make(category: "ExamScheduleSelectionViewModel")

    private var registeredApplicationId: Int?
    private var registeredUserApplyId: Int?

    // MARK: - Initialization

    init(examScheduleService: ExamScheduleService) {
        self.examScheduleService = examScheduleService
    }

    // MARK: - Methods

    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink { [weak self] event in
                guard let self else { return }
                switch event {
                case .viewDidLoad:
                    Task { [weak self] in await self?.loadExamList() }

                case .examTapped(let id):
                    Task { [weak self] in await self?.handleExamTapped(id: id) }
                }
            }
            .store(in: &cancellables)

        return outputSubject.eraseToAnyPublisher()
    }

    private func loadExamList() async {
        do {
            let response = try await examScheduleService.fetchExamList()
            registeredApplicationId = response.data.registeredApplicationId
            registeredUserApplyId = response.data.registeredUserApplyId

            let rows = response.convert()
            outputSubject.send(.loadExamList(rows: rows))

        } catch let error as NetworkError {
            outputSubject.send(.showErrorAlert(error.errorMessage))
            logger.error("NetworkError(fetchExamList): \(error.debugDescription, privacy: .public)")

        } catch {
            outputSubject.send(.showErrorAlert("목록을 불러오지 못했습니다."))
            logger.error("Unhandled error(fetchExamList): \(error.localizedDescription, privacy: .public)")
        }
    }

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
            logger.error("NetworkError(handleExamTapped): \(error.debugDescription, privacy: .public)")

        } catch {
            outputSubject.send(.showErrorAlert("시험 정보를 불러오지 못했습니다."))
            logger.error("Unhandled error(handleExamTapped): \(error.localizedDescription, privacy: .public)")
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
