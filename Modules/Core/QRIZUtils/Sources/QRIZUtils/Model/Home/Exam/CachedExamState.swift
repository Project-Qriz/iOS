//
//  CachedExamState.swift
//  QRIZUtils
//

import Foundation

/// 등록 시험 캐시 값. "미등록"도 유효한 캐시 값이며, 캐시가 아예 없는 상태와는 구분된다.
public enum CachedExamValue: Codable, Equatable, Sendable {
    case registered(ExamDetail)
    case unregistered
}

/// 로컬에 저장되는 등록 시험 캐시. `fetchedAt`은 디버깅용으로만 보관하며 재검증 판단에는 쓰지 않는다.
public struct CachedExamState: Codable, Equatable, Sendable {
    public let value: CachedExamValue
    public let fetchedAt: Date

    public init(value: CachedExamValue, fetchedAt: Date) {
        self.value = value
        self.fetchedAt = fetchedAt
    }
}
