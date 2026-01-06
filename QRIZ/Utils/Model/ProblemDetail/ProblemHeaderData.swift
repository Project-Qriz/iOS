//
//  ProblemHeaderData.swift
//  QRIZ
//
//  Created by Claude on 12/30/25.
//

import Foundation

struct ProblemHeaderData {
    let isCorrect: Bool             // 정답 여부
    let examTitle: String           // "2023년도 모의고사"
    let subject: String             // "1과목"
    let questionNumber: Int         // 5
    let tags: [String]              // ["엔터티", "식별자"]
}
