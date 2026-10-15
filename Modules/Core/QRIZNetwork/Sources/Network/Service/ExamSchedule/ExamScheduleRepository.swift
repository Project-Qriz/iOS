//
//  ExamScheduleRepository.swift
//  QRIZNetwork
//

import Foundation
import os
import QRIZUtils

@MainActor
public protocol ExamScheduleRepository: Sendable {
    /// 캐시가 있으면 반환, 없으면 fetch 후 저장 (TTL 없음)
    /// 400은 항상 `.unregistered`로 반환하고, 미등록 신호가 정확히 일치할 때만 캐시
    func currentExamState() async throws -> CachedExamValue
    /// 쓰기 성공 결과로 캐시 덮어쓰기
    func applyWriteResult(_ detail: ExamDetail)
    /// 로그아웃 · 세션 만료 · 회원 탈퇴 시 호출
    func clearCache()
}

@MainActor
public final class ExamScheduleRepositoryImpl: ExamScheduleRepository {

    private let service: ExamScheduleService
    private let cacheStore: ExamScheduleCacheStore
    private let userInfo: UserInfoManager
    private let logger = Logger.make(category: "ExamScheduleRepository")
    private var inFlightTask: Task<CachedExamValue, Error>?
    // 미등록 400 신호 (코드만으로는 다른 400과 겹칠 수 있어 메시지도 확인)
    private static let unregisteredServerCode = -1
    private static let unregisteredMessage = "등록된 일정이 없어요"

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
        // 진행 중인 fetch는 쓰기 이전 값이라 취소
        inFlightTask?.cancel()
        inFlightTask = nil
        cacheStore.save(CachedExamState(value: .registered(detail), fetchedAt: Date()), userId: userInfo.userId)
    }

    public func clearCache() {
        cacheStore.clear(userId: userInfo.userId)
        // 취소하지 않으면 진행 중인 fetch가 캐시를 되살림
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
            // 취소됐으면 저장하지 않음
            guard !Task.isCancelled else { return value }
            cacheStore.save(CachedExamState(value: value, fetchedAt: Date()), userId: userId)
            return value

        } catch let NetworkError.clientError(httpStatus, serverCode, message, _, _)
            where httpStatus == 400
                && serverCode == Self.unregisteredServerCode
                && message == Self.unregisteredMessage {
            // 미등록 신호 일치 → 미등록으로 캐시
            let value = CachedExamValue.unregistered
            guard !Task.isCancelled else { return value }
            cacheStore.save(CachedExamState(value: value, fetchedAt: Date()), userId: userId)
            return value

        } catch let NetworkError.clientError(httpStatus, serverCode, message, _, _) where httpStatus == 400 {
            // 신호 불일치 → 화면엔 미등록으로 보여주되 캐시하지 않음
            logger.warning("fetchAppliedExams 400이 예상 신호와 다름 — serverCode=\(String(describing: serverCode), privacy: .public), message=\(message, privacy: .public)")
            return .unregistered
        }
    }
}
