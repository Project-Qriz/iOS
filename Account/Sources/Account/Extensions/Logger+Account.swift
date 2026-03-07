//
//  Logger+Account.swift
//  QRIZ
//
//  Created by 김세훈 on 3/8/26.
//

import os
import Foundation

extension Logger {
    static func account(category: String) -> Logger {
        Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.ksh.qriz", category: category)
    }
}
