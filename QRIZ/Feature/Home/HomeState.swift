//
//  HomeState.swift
//  QRIZ
//
//  Created by 김세훈 on 5/27/25.
//

import Foundation

struct HomeState: Equatable {
    var examItem: ExamScheduleItem
    var entryState: ExamEntryCardCell.State
}
