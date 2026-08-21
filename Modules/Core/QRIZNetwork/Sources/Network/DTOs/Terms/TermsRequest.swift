public struct TermsRequest: Request, Sendable {
    public typealias Response = TermsResponse

    public let path = "/api/terms"
    public let method: HTTPMethod = .get

    public init() {}
}

public struct TermsResponse: Decodable, Sendable {
    public let code: Int
    public let msg: String
    public let data: [TermsListItem]

    public init(code: Int, msg: String, data: [TermsListItem]) {
        self.code = code
        self.msg = msg
        self.data = data
    }
}

public struct TermsListItem: Decodable, Sendable {
    public let id: Int
    public let title: String
    public let documentUrl: String?

    public init(id: Int, title: String, documentUrl: String?) {
        self.id = id
        self.title = title
        self.documentUrl = documentUrl
    }
}
