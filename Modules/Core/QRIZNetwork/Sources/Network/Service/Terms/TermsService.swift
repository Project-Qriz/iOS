public protocol TermsService: Sendable {
    /// 현행 약관 목록 조회 (비로그인 호출 가능)
    func fetchTerms() async throws -> TermsResponse
}

public final class TermsServiceImpl: TermsService, Sendable {
    private let network: Network

    public init(network: Network) {
        self.network = network
    }

    public func fetchTerms() async throws -> TermsResponse {
        try await network.send(TermsRequest())
    }
}
