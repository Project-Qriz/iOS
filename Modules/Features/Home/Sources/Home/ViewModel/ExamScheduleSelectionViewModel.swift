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
import QRIZNetwork

@MainActor
final class ExamScheduleSelectionViewModel {

    // MARK: - Properties

    weak var delegate: ExamSelectionDelegate?
    private let examScheduleService: ExamScheduleService
    private let examScheduleRepository: any ExamScheduleRepository
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger.make(category: "ExamScheduleSelectionViewModel")

    private var registeredApplicationId: Int?
    private var registeredUserApplyId: Int?
    private var latestRows: [ExamRowState] = []
    private var latestApplications: [ExamInfo] = []

    // MARK: - Initialization

    init(examScheduleService: ExamScheduleService, examScheduleRepository: any ExamScheduleRepository) {
        self.examScheduleService = examScheduleService
        self.examScheduleRepository = examScheduleRepository
    }

    // MARK: - Methods

    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink { [weak self] event in
                guard let self else { return }
                switch event {
                case .viewDidLoad:
                    Task { [weak self] in _ = await self?.loadExamList() }

                case .examTapped(let id):
                    Task { [weak self] in await self?.handleExamTapped(id: id) }
                }
            }
            .store(in: &cancellables)

        return outputSubject.eraseToAnyPublisher()
    }

    /// - Returns: 성공 여부 (실패 시 내부 상태가 갱신되지 않았으므로 캐시 동기화 금지)
    private func loadExamList() async -> Bool {
        do {
            let response = try await examScheduleService.fetchExamList()
            registeredApplicationId = response.data.registeredApplicationId
            registeredUserApplyId = response.data.registeredUserApplyId
            latestApplications = response.data.applications

            let rows = response.convert()
            latestRows = rows
            outputSubject.send(.loadExamList(rows: rows))
            return true

        } catch let error as NetworkError {
            outputSubject.send(.showErrorAlert(error.errorMessage))
            logger.error("NetworkError(fetchExamList): \(error.debugDescription, privacy: .public)")
            return false

        } catch {
            outputSubject.send(.showErrorAlert("목록을 불러오지 못했습니다."))
            logger.error("Unhandled error(fetchExamList): \(error.localizedDescription, privacy: .public)")
            return false
        }
    }

    private func handleExamTapped(id: Int) async {
        guard id != registeredApplicationId else { return }

        let previousRows = latestRows
        showOptimisticSelection(for: id)

        do {
            if let userApplyId = registeredUserApplyId {
                _ = try await examScheduleService.updateExamSchedule(
                    userApplyId: userApplyId,
                    newApplyId: id
                )
            } else {
                _ = try await examScheduleService.applyExamSchedule(applyId: id)
            }

            // 재조회 실패 시 서버 상태를 모르므로 캐시를 비움
            if await loadExamList() {
                syncRepositoryCache()
            } else {
                examScheduleRepository.clearCache()
            }
            delegate?.didUpdateExamSchedule()

        } catch let urlError as URLError where Self.isTransportTimeout(urlError) {
            // 결과 불명 → 롤백 대신 서버 상태로 확정
            if await loadExamList() {
                syncRepositoryCache()
                if registeredApplicationId == id {
                    delegate?.didUpdateExamSchedule()
                }
            } else {
                // 서버 상태를 모르므로 캐시만 비우고 delegate는 호출하지 않음
                examScheduleRepository.clearCache()
            }

        } catch let error as NetworkError {
            rollback(to: previousRows)
            outputSubject.send(.showErrorAlert(error.errorMessage))
            logger.error("NetworkError(handleExamTapped): \(error.debugDescription, privacy: .public)")

        } catch {
            rollback(to: previousRows)
            outputSubject.send(.showErrorAlert("시험 정보를 저장하지 못했습니다."))
            logger.error("Unhandled error(handleExamTapped): \(error.localizedDescription, privacy: .public)")
        }
    }

    /// 응답 전에 탭한 항목을 선택 상태로 먼저 표시
    private func showOptimisticSelection(for id: Int) {
        let optimisticRows = latestRows.map { row in
            ExamRowState(
                id: row.id,
                examName: row.examName,
                periodText: row.periodText,
                dateText: row.dateText,
                isSelected: row.id == id,
                isExpired: row.isExpired
            )
        }
        latestRows = optimisticRows
        outputSubject.send(.loadExamList(rows: optimisticRows))
    }

    private func rollback(to rows: [ExamRowState]) {
        latestRows = rows
        outputSubject.send(.loadExamList(rows: rows))
    }

    /// 재조회한 등록 상태를 캐시에 반영 (특정할 수 없으면 캐시를 비움)
    private func syncRepositoryCache() {
        guard let registeredId = registeredApplicationId,
              let matched = latestApplications.first(where: { $0.applicationId == registeredId }) else {
            examScheduleRepository.clearCache()
            return
        }

        let detail = ExamDetail(
            examDateText: matched.examDate,
            examName: matched.examName,
            applyPeriod: matched.period
        )
        examScheduleRepository.applyWriteResult(detail)
    }

    private static func isTransportTimeout(_ error: URLError) -> Bool {
        switch error.code {
        // 요청이 서버에 닿았는지 알 수 없는 경우만 (오프라인 등은 즉시 롤백)
        case .timedOut, .networkConnectionLost, .cannotConnectToHost:
            return true
        default:
            return false
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
