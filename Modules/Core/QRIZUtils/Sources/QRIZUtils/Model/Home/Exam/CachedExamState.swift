//
//  CachedExamState.swift
//  QRIZUtils
//

import Foundation

/// 등록 시험 캐시 값 ("미등록"도 캐시 값이며 캐시 없음과 구분)
public enum CachedExamValue: Codable, Equatable, Sendable {
    case registered(ExamDetail)
    case unregistered
}

/// 로컬에 저장되는 등록 시험 캐시 (`fetchedAt`은 디버깅용)
public struct CachedExamState: Codable, Equatable, Sendable {
    public let value: CachedExamValue
    public let fetchedAt: Date

    public init(value: CachedExamValue, fetchedAt: Date) {
        self.value = value
        self.fetchedAt = fetchedAt
    }
}
