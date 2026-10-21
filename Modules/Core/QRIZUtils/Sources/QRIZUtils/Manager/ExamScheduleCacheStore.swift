//
//  ExamScheduleCacheStore.swift
//  QRIZUtils
//

import Foundation

@MainActor
public protocol ExamScheduleCacheStore: Sendable {
    func load(userId: String) -> CachedExamState?
    func save(_ state: CachedExamState, userId: String)
    func clear(userId: String)
}

@MainActor
public final class ExamScheduleCacheStoreImpl: ExamScheduleCacheStore, Sendable {

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public func load(userId: String) -> CachedExamState? {
        guard let data = defaults.data(forKey: key(for: userId)) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(CachedExamState.self, from: data)
    }

    public func save(_ state: CachedExamState, userId: String) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(state) else { return }
        defaults.set(data, forKey: key(for: userId))
    }

    public func clear(userId: String) {
        defaults.removeObject(forKey: key(for: userId))
    }

    private func key(for userId: String) -> String {
        "examSchedule.cache.\(userId)"
    }
}
