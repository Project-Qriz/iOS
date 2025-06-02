//
//  UserInfoManager.swift
//  QRIZ
//
//  Created by ch on 4/24/25.
//

import Foundation

final class UserInfoManager {
    
    static let shared = UserInfoManager()
    
    private init() {}
    
    var name: String = ""
    var userId: String = ""
    var email: String = ""
    var previewTestStatus: PreviewTestStatus = .notStarted
    var provider: String? = nil
    
    func update(from response: UserInfo) {
        name = response.name
        userId = response.userId
        email = response.email
        previewTestStatus = response.previewTestStatus
        provider = response.provider
    }
    
    func reset() {
        name = ""
        userId = ""
        email = ""
        previewTestStatus = .notStarted
        provider = nil
    }
}
