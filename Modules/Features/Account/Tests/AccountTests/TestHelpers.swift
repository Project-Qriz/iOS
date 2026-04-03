//
//  TestHelpers.swift
//  AccountTests
//

import Combine

let asyncSleepNanoseconds: UInt64 = 100_000_000

@MainActor
func collect<Output>(
    _ publisher: AnyPublisher<Output, Never>,
    during action: () -> Void
) -> [Output] {
    var outputs: [Output] = []
    let cancellable = publisher.sink { outputs.append($0) }
    action()
    cancellable.cancel()
    return outputs
}

@MainActor
func collectAsync<Output>(
    _ publisher: AnyPublisher<Output, Never>,
    during action: () -> Void
) async throws -> [Output] {
    var outputs: [Output] = []
    let cancellable = publisher.sink { outputs.append($0) }
    action()
    try await Task.sleep(nanoseconds: asyncSleepNanoseconds)
    cancellable.cancel()
    return outputs
}
