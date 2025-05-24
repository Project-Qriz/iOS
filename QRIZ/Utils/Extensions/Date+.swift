//
//  Date+.swift
//  QRIZ
//
//  Created by 김세훈 on 5/8/25.
//

import Foundation

extension Date {
    /// `오늘의 날짜를 MM * 100 + dd 정수로 (5월 8일 → 508) 변환해주는 연산 프로퍼티입니다.`
    static var todayMonthDay: Int {
        let cal = Calendar.current
        return cal.component(.month, from: Date()) * 100 + cal.component(.day, from: Date())
    }
}

/// `3월 8일(토) 형식의 날짜를 MM * 100 + dd 형태의 정수로 (예: 3월 8일 → 308) 변환해주는 연산 프로퍼티입니다.`
func monthDay(from str: String) -> Int? {
    guard
        let md = str.split(separator: "(").first,
        let m = md.split(separator: "월").first,
        let dS = md.split(separator: "월").last?
            .replacingOccurrences(of: "일", with: "")
            .trimmingCharacters(in: .whitespaces),
        let month = Int(m), let day = Int(dS)
    else { return nil }
    return month * 100 + day
}
