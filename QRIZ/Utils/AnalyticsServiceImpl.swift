//
//  AnalyticsServiceImpl.swift
//  QRIZ
//
//  Created by 김세훈 on 4/5/26.
//

import FirebaseAnalytics
import QRIZUtils

final class AnalyticsServiceImpl: AnalyticsService, @unchecked Sendable {

    func log(_ event: AnalyticsEvent) {
        switch event {
        case .screenView(let name):
            Analytics.logEvent(AnalyticsEventScreenView, parameters: [
                AnalyticsParameterScreenName: name.rawValue
            ])

        case .login(let method):
            Analytics.logEvent(AnalyticsEventLogin, parameters: [
                AnalyticsParameterMethod: method.rawValue
            ])

        case .logout:
            Analytics.logEvent("logout", parameters: nil)

        case .examStart:
            Analytics.logEvent("exam_start", parameters: nil)

        case .examComplete(let score, let total):
            Analytics.logEvent("exam_complete", parameters: [
                "score": score,
                "total": total
            ])

        case .examAbandon:
            Analytics.logEvent("exam_abandon", parameters: nil)

        case .dailyComplete:
            Analytics.logEvent("daily_complete", parameters: nil)

        case .apiError(let endpoint, let statusCode, let message):
            Analytics.logEvent("api_error", parameters: [
                "endpoint": endpoint,
                "status_code": statusCode,
                "error_message": message
            ])
        }
    }
}
