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
            latestApplications = response.data.applications

            let rows = response.convert()
            latestRows = rows
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

            await loadExamList()
            syncRepositoryCache()
            delegate?.didUpdateExamSchedule()

        } catch let urlError as URLError where Self.isTransportTimeout(urlError) {
            // 결과 불명: 롤백하지 않고 서버 상태를 다시 받아 동기화한다
            await loadExamList()
            syncRepositoryCache()
            if registeredApplicationId == id {
                delegate?.didUpdateExamSchedule()
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

    /// 쓰기 요청을 보내기 전에, 방금 탭한 항목이 선택된 것처럼 화면을 먼저 갱신한다.
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

    /// 재조회로 확인된 등록 상태를 Repository 캐시에 직접 반영한다 (다시 fetch하지 않는다).
    private func syncRepositoryCache() {
        guard let registeredId = registeredApplicationId,
              let matched = latestApplications.first(where: { $0.applicationId == registeredId }) else { return }

        let detail = ExamDetail(
            examDateText: matched.examDate,
            examName: matched.examName,
            applyPeriod: matched.period
        )
        examScheduleRepository.applyWriteResult(detail)
    }

    private static func isTransportTimeout(_ error: URLError) -> Bool {
        switch error.code {
        case .timedOut, .networkConnectionLost, .notConnectedToInternet, .cannotConnectToHost, .cannotFindHost, .dnsLookupFailed:
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
