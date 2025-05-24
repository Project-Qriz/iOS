//
//  ExamRowState.swift
//  QRIZ
//
//  Created by 김세훈 on 5/8/25.
//

import Foundation

struct ExamRowState: Hashable {
    let id: Int
    let examName: String
    let periodText: String
    let dateText: String
    let isSelected: Bool
    let isExpired: Bool
}
