//
//  SpyAnalyticsService.swift
//  AccountTests
//

import QRIZUtils

@MainActor
final class SpyAnalyticsService: AnalyticsService {
    private(set) var loggedEvents: [String] = []

    /// AnalyticsEvent가 Equatable이 아니라 비교하기 쉬운 문자열로 기록한다.
    func log(_ event: AnalyticsEvent) {
        loggedEvents.append(String(describing: event))
    }
}
