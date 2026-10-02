//
//  ExamScheduleRepository.swift
//  QRIZNetwork
//

import Foundation
import QRIZUtils

@MainActor
public protocol ExamScheduleRepository: Sendable {
    /// 캐시가 있으면 즉시 반환한다. 없으면 서버에서 1회 fetch한 뒤 저장하고 반환한다.
    /// 타이머·TTL로 재검증하지 않는다 — 캐시가 있으면 영원히 그대로 쓴다.
    func currentExamState() async throws -> CachedExamValue
    /// 등록·변경 성공으로 확인된 서버 상태로 캐시를 직접 덮어쓴다. 재조회하지 않는다.
    func applyWriteResult(_ detail: ExamDetail)
    /// 로그아웃 · 세션 만료 · 회원 탈퇴 시 캐시를 비운다.
    func clearCache()
}

@MainActor
public final class ExamScheduleRepositoryImpl: ExamScheduleRepository {

    private let service: ExamScheduleService
    private let cacheStore: ExamScheduleCacheStore
    private let userInfo: UserInfoManager
    private var inFlightTask: Task<CachedExamValue, Error>?

    public init(
        service: ExamScheduleService,
        cacheStore: ExamScheduleCacheStore,
        userInfo: UserInfoManager = .shared
    ) {
        self.service = service
        self.cacheStore = cacheStore
        self.userInfo = userInfo
    }

    public func currentExamState() async throws -> CachedExamValue {
        let userId = userInfo.userId
        if let cached = cacheStore.load(userId: userId) {
            return cached.value
        }
        if let inFlightTask {
            return try await inFlightTask.value
        }

        let task = Task { try await self.fetchAndCache(userId: userId) }
        inFlightTask = task
        defer { inFlightTask = nil }
        return try await task.value
    }

    public func applyWriteResult(_ detail: ExamDetail) {
        cacheStore.save(CachedExamState(value: .registered(detail), fetchedAt: Date()), userId: userInfo.userId)
    }

    public func clearCache() {
        cacheStore.clear(userId: userInfo.userId)
        // 참조만 버리면 진행 중인 fetch가 끝나면서 캐시를 되살린다 → 반드시 취소한다
        inFlightTask?.cancel()
        inFlightTask = nil
    }

    private func fetchAndCache(userId: String) async throws -> CachedExamValue {
        do {
            let response = try await service.fetchAppliedExams()
            let detail = ExamDetail(
                examDateText: response.data.examDate,
                examName: response.data.examName,
                applyPeriod: response.data.period
            )
            let value = CachedExamValue.registered(detail)
            // 취소됐다면(로그아웃 등) 캐시를 되살리지 않는다
            guard !Task.isCancelled else { return value }
            cacheStore.save(CachedExamState(value: value, fetchedAt: Date()), userId: userId)
            return value

        } catch let NetworkError.clientError(httpStatus, _, _, _, _) where httpStatus == 400 {
            // 시험 미등록 상태 → 정상 케이스로 캐시한다
            let value = CachedExamValue.unregistered
            // 취소됐다면(로그아웃 등) 캐시를 되살리지 않는다
            guard !Task.isCancelled else { return value }
            cacheStore.save(CachedExamState(value: value, fetchedAt: Date()), userId: userId)
            return value
        }
    }
}
