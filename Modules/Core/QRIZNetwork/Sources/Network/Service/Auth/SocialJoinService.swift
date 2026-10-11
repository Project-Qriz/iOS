public protocol SocialJoinService: Sendable {
    func join(onboardingToken: String, over14Confirmed: Bool, agreedTermIds: [Int]) async throws -> SocialLoginResponse
}

public final class SocialJoinServiceImpl: SocialJoinService, Sendable {
    private let network: Network

    public init(network: Network) {
        self.network = network
    }

    public func join(onboardingToken: String, over14Confirmed: Bool, agreedTermIds: [Int]) async throws -> SocialLoginResponse {
        let request = SocialJoinRequest(
            onboardingToken: onboardingToken,
            over14Confirmed: over14Confirmed,
            agreedTermIds: agreedTermIds
        )
        return try await network.send(request)
    }
}
