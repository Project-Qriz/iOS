//
//  UserInfoManager.swift
//  QRIZ
//
//  Created by ch on 4/24/25.
//

import Foundation

struct UserInfoManager {
    static var name: String = "채영" // 임시 값, 추후에 UserInfoService를 통해 갱신
    static var userId: String = ""
    static var email: String = ""
    static var previewTestStatus: PreviewTestStatus = .previewCompleted
    static var provider: String? = nil
}
