//
//  PreviewTestStatus.swift
//  QRIZ
//
//  Created by ch on 4/24/25.
//

import Foundation

enum PreviewTestStatus: String, Codable {
    case notStarted = "NOT_STARTED" // 설문조사 실시하지 않음
    case previewSkipped = "PREVIEW_SKIPPED" // 설문조사에서 아무것도 몰라요 선택
    case surveyCompleted = "SURVEY_COMPLETED" // 설문조사에서 선택한 개념이 존재 + 프리뷰 테스트 실시하지 않음
    case previewCompleted = "PREVIEW_COMPLETED" // 프리뷰 테스트 완료
}
