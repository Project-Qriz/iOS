public protocol ConsentsService: Sendable {
    func submitConsents(accessToken: String, over14Confirmed: Bool, agreedTermIds: [Int]) async throws -> ConsentsResponse
}

public final class ConsentsServiceImpl: ConsentsService, Sendable {
    private let network: Network

    public init(network: Network) {
        self.network = network
    }

    public func submitConsents(accessToken: String, over14Confirmed: Bool, agreedTermIds: [Int]) async throws -> ConsentsResponse {
        let request = ConsentsRequest(accessToken: accessToken, over14Confirmed: over14Confirmed, agreedTermIds: agreedTermIds)
        return try await network.send(request)
    }
}
