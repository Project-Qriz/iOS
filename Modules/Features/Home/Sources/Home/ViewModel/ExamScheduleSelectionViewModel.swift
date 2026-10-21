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

    /// 목록을 재조회해 내부 상태(`registeredApplicationId` 등)를 서버 기준으로 갱신한다.
    /// - Returns: 성공 여부. 실패하면 내부 상태가 갱신되지 않았음을 뜻하므로,
    ///            호출자는 이 값을 캐시 동기화 여부 판단에 반드시 사용해야 한다.
    ///            (`@discardableResult`를 붙이지 않아 무시하면 경고가 난다)
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

            // 쓰기는 성공했으나 재조회가 실패하면 내부 상태가 서버와 어긋난 채로 남는다.
            // 그 상태를 캐시에 쓰면 영구히 오염되므로(TTL 없음), 캐시를 비워 다음 읽기에서
            // 정상 fetch가 일어나게 한다.
            if await loadExamList() {
                syncRepositoryCache()
            } else {
                examScheduleRepository.clearCache()
            }
            delegate?.didUpdateExamSchedule()

        } catch let urlError as URLError where Self.isTransportTimeout(urlError) {
            // 결과 불명: 롤백하지 않고 서버 상태를 다시 받아 동기화한다
            if await loadExamList() {
                syncRepositoryCache()
                if registeredApplicationId == id {
                    delegate?.didUpdateExamSchedule()
                }
            } else {
                // 쓰기 결과도, 서버 상태도 모르는 상태. 캐시를 비워 다음 읽기에서
                // 실제 서버 상태를 받게 하고, 성공 신호(delegate)는 보내지 않는다.
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
    /// 재조회 결과에서 등록 상태를 특정할 수 없으면 낡은 값을 남기지 않도록 캐시를 비운다.
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
        // 요청이 서버에 닿았는지 알 수 없는(= reconcile이 필요한) 경우만 포함한다.
        // `.notConnectedToInternet` · `.cannotFindHost` · `.dnsLookupFailed`처럼
        // 요청이 서버에 닿지 않았음이 명확한 에러는 일반 catch로 넘겨 즉시 롤백시킨다.
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
