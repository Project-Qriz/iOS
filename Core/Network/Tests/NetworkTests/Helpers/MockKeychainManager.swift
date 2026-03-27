//
//  MockKeychainManager.swift
//  NetworkTests
//
//  Created by Claude on 2/22/26.
//

import QRIZUtils

final class MockKeychainManager: KeychainManager {

    var storage: [String: String] = [:]
    var saveCallCount = 0
    var deleteCallCount = 0

    func save(token: String, forKey key: String) -> Bool {
        saveCallCount += 1
        storage[key] = token
        return true
    }

    func retrieveToken(forKey key: String) -> String? {
        storage[key]
    }

    func deleteToken(forKey key: String) {
        deleteCallCount += 1
        storage.removeValue(forKey: key)
    }

    func reset() {
        storage = [:]
        saveCallCount = 0
        deleteCallCount = 0
    }
}
