//
//  ExamScheduleRepository.swift
//  QRIZNetwork
//

import Foundation
import os
import QRIZUtils

@MainActor
public protocol ExamScheduleRepository: Sendable {
    /// 캐시가 있으면 즉시 반환한다. 없으면 서버에서 1회 fetch한 뒤 저장하고 반환한다.
    /// 타이머·TTL로 재검증하지 않는다 — 캐시가 있으면 영원히 그대로 쓴다.
    /// 조회 API의 400은 항상 `.unregistered`로 반환한다(= 에러로 던지지 않는다). 시험 미등록은
    /// 정상 상태이므로 화면에 에러 알럿을 띄울 수 없다. 서버가 보낸 신호(코드+메시지)가 알려진
    /// "미등록" 신호와 정확히 일치할 때만 캐시에 쓰고, 다르면 캐시하지 않고 다음 읽기에서 다시 확인한다.
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
    private let logger = Logger.make(category: "ExamScheduleRepository")
    private var inFlightTask: Task<CachedExamValue, Error>?
    /// 조회 API가 "등록된 일정 없음"을 나타낼 때 내려주는 서버 코드 (400 응답의 code)
    private static let unregisteredServerCode = -1
    /// serverCode만으로는 다른 400과 겹칠 위험이 있어, 메시지까지 같이 확인한다.
    /// 둘 중 하나라도 안 맞으면 캐시하지 않는다 (화면엔 여전히 미등록으로 보여준다 — 아래 두 번째 400 catch 참고).
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

        } catch let NetworkError.clientError(httpStatus, serverCode, message, _, _)
            where httpStatus == 400
                && serverCode == Self.unregisteredServerCode
                && message == Self.unregisteredMessage {
            // 서버가 "등록된 일정이 없음"을 코드와 메시지로 모두 확인해준 경우 → 미등록으로 캐시한다.
            let value = CachedExamValue.unregistered
            // 취소됐다면(로그아웃 등) 캐시를 되살리지 않는다
            guard !Task.isCancelled else { return value }
            cacheStore.save(CachedExamState(value: value, fetchedAt: Date()), userId: userId)
            return value

        } catch let NetworkError.clientError(httpStatus, serverCode, message, _, _) where httpStatus == 400 {
            // 이 엔드포인트의 400은 실질적으로 "미등록"을 뜻한다. 신호(코드+메시지)가 예상과
            // 다르더라도 화면에는 에러 알럿을 띄우지 않고 미등록으로 보여준다 — 시험을 아직
            // 등록하지 않은, 완전히 정상적인 상태에 에러를 보여줄 수는 없다.
            // 다만 신호가 예상과 다르므로 캐시에는 쓰지 않는다 (다음 읽기에서 다시 확인).
            logger.warning("fetchAppliedExams 400이 예상 신호와 다름 — serverCode=\(String(describing: serverCode), privacy: .public), message=\(message, privacy: .public)")
            return .unregistered
        }
    }
}
