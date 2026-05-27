import QRIZUtils

public struct DailyPlanChangeAvailableRequest: Request, Sendable {
    public typealias Response = DailyPlanChangeAvailableResponse

    public let path = "/api/v1/daily/plan/change-available"
    public let method: HTTPMethod = .get
    private let accessToken: String

    public var headers: HTTPHeader {
        [
            HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue,
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }

    public init(accessToken: String) {
        self.accessToken = accessToken
    }
}

public struct DailyPlanChangeAvailableResponse: Decodable, Sendable {
    public let code: Int
    public let msg: String
    public let data: DataInfo

    public init(code: Int, msg: String, data: DataInfo) {
        self.code = code
        self.msg = msg
        self.data = data
    }

    public struct DataInfo: Decodable, Sendable {
        public let currentPlanType: Int
        public let completedDays: Int
        public let availablePlanTypes: [Int]

        public init(currentPlanType: Int, completedDays: Int, availablePlanTypes: [Int]) {
            self.currentPlanType = currentPlanType
            self.completedDays = completedDays
            self.availablePlanTypes = availablePlanTypes
        }
    }
}
