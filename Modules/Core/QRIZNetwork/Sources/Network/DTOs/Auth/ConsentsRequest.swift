public struct ConsentsRequest: Request, Sendable {
    public typealias Response = ConsentsResponse

    public let path = "/api/v1/consents"
    public let method: HTTPMethod = .post
    private let accessToken: String
    public let over14Confirmed: Bool
    public let agreedTermIds: [Int]

    public var body: Encodable? {
        ConsentsRequestBody(over14Confirmed: over14Confirmed, agreedTermIds: agreedTermIds)
    }

    public var headers: HTTPHeader {
        [
            HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue,
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }

    public init(accessToken: String, over14Confirmed: Bool, agreedTermIds: [Int]) {
        self.accessToken = accessToken
        self.over14Confirmed = over14Confirmed
        self.agreedTermIds = agreedTermIds
    }
}

private struct ConsentsRequestBody: Encodable {
    let over14Confirmed: Bool
    let agreedTermIds: [Int]
}

public struct ConsentsResponse: Decodable, Sendable {
    public let code: Int
    public let msg: String
    public let data: DataInfo

    public init(code: Int, msg: String, data: DataInfo) {
        self.code = code
        self.msg = msg
        self.data = data
    }

    public struct DataInfo: Decodable, Sendable {
        public let reAgreementRequired: Bool
        public let ageVerificationRequired: Bool

        public init(reAgreementRequired: Bool, ageVerificationRequired: Bool) {
            self.reAgreementRequired = reAgreementRequired
            self.ageVerificationRequired = ageVerificationRequired
        }
    }
}
