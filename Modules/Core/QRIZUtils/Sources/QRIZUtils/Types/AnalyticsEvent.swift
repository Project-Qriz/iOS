//
//  AnalyticsEvent.swift
//  QRIZUtils
//
//  Created by 김세훈 on 4/5/26.
//

public enum AnalyticsEvent: Sendable {

    // MARK: - Screen

    case screenView(ScreenName)

    // MARK: - Auth

    case login(LoginMethod)
    case logout

    // MARK: - Exam

    case examStart
    case examComplete(score: Int, total: Int)
    case examAbandon

    // MARK: - Daily

    case dailyComplete

    // MARK: - API

    case apiError(endpoint: String, statusCode: Int, message: String)
}

// MARK: - Nested Types

public extension AnalyticsEvent {
    enum ScreenName: String, Sendable {
        case login
        case home
        case examList = "exam_list"
        case examTest = "exam_test"
        case examResult = "exam_result"
        case examSummary = "exam_summary"
        case daily
        case conceptBook = "concept_book"
        case myPage = "my_page"
        case onboarding
        case mistakeNote = "mistake_note"
    }

    enum LoginMethod: String, Sendable {
        case email
        case kakao
        case google
        case apple
        case unknown
    }
}
