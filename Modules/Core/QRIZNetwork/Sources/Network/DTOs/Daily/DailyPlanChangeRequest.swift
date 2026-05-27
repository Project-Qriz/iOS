import QRIZUtils

public struct DailyPlanChangeRequest: Request, Sendable {
    public typealias Response = DailyPlanChangeResponse

    public let path = "/api/v1/daily/plan/change"
    public let method: HTTPMethod = .post
    private let accessToken: String
    private let planType: Int

    public var headers: HTTPHeader {
        [
            HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue,
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }

    public var body: Encodable? {
        ["planType": planType]
    }

    public init(accessToken: String, planType: Int) {
        self.accessToken = accessToken
        self.planType = planType
    }
}

public struct DailyPlanChangeResponse: Decodable, Sendable {
    public let code: Int
    public let msg: String

    public init(code: Int, msg: String) {
        self.code = code
        self.msg = msg
    }
}
