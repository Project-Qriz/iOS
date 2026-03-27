//
//  Date+.swift
//  QRIZUtils
//
//  Created by 김세훈 on 5/8/25.
//

import Foundation

public extension Date {

    private static let graphTextFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd"
        return formatter
    }()

    /// `오늘의 날짜를 MM * 100 + dd 정수로 (5월 8일 → 508) 변환해주는 연산 프로퍼티입니다.`
    static var todayMonthDay: Int {
        let cal = Calendar.current
        return cal.component(.month, from: Date()) * 100 + cal.component(.day, from: Date())
    }

    /// `점수 변동 그래프를 위한 날짜 변환기입니다.`
    var graphText: String {
        Self.graphTextFormatter.string(from: self)
    }
}
