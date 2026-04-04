//
//  AnalyticsService.swift
//  QRIZUtils
//
//  Created by 김세훈 on 4/5/26.
//

@MainActor
public protocol AnalyticsService: Sendable {
    func log(_ event: AnalyticsEvent)
}

@MainActor
public final class AnalyticsManager: AnalyticsService {

    public static let shared = AnalyticsManager()

    private var service: (any AnalyticsService)?

    private init() {}

    public func configure(service: any AnalyticsService) {
        self.service = service
    }

    public func log(_ event: AnalyticsEvent) {
        service?.log(event)
    }
}
