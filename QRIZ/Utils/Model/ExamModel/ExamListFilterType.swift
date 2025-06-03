//
//  ExamListFilterType.swift
//  QRIZ
//
//  Created by 이창현 on 5/11/25.
//

import Foundation

enum ExamListFilterType: String, CaseIterable, Comparable {
    case total = "전체"
    case incomplete = "학습 전"
    case completed = "학습 후"
    case sortByDate = "과거 순"
    
    // 메뉴 아이템 삽입 순서를 위한 Comparable
    static func < (lhs: ExamListFilterType, rhs: ExamListFilterType) -> Bool {
        lhs.priority < rhs.priority
    }
    
    private var priority: Int {
        switch self {
        case .total: return 0
        case .incomplete: return 1
        case .completed: return 2
        case .sortByDate: return 3
        }
    }
    
    var queryParameter: [String: String] {
        switch self {
        case .incomplete:
            return ["status": "incomplete"]
        case .completed:
            return ["status": "completed"]
        case .sortByDate:
            return ["sort": "asc"]
        default:
            return [:]
        }
    }
}
