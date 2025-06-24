//
//  HomeState.swift
//  QRIZ
//
//  Created by 김세훈 on 5/27/25.
//

import Foundation

struct HomeState: Equatable {
    var userName: String
    var examStatus: ExamStatus
    var entryState: EntryCardState
}

enum ExamStatus: Equatable, Hashable {
    case none
    case expired(detail: ExamDetail)
    case registered(dDay: Int, detail: ExamDetail)
}

struct ExamDetail: Equatable, Hashable {
    let examDateText: String
    let examName: String
    let applyPeriod: String
}

enum EntryCardState: Equatable, Hashable {
    case preview
    case mock
}
