//
//  UserInfoManager.swift
//  QRIZUtils
//
//  Created by ch on 4/24/25.
//

import Foundation

public final class UserInfoManager {

    public static let shared = UserInfoManager()

    private init() {}

    public var name: String = ""
    public var userId: String = ""
    public var email: String = ""
    public var previewTestStatus: PreviewTestStatus = .notStarted
    public var provider: String? = nil

    public func update(name: String, userId: String, email: String, previewTestStatus: PreviewTestStatus, provider: String?) {
        self.name = name
        self.userId = userId
        self.email = email
        self.previewTestStatus = previewTestStatus
        self.provider = provider
    }

    public func reset() {
        name = ""
        userId = ""
        email = ""
        previewTestStatus = .notStarted
        provider = nil
    }
}
