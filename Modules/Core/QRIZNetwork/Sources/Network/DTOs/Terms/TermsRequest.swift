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

/// 서버가 새 약관 타입을 추가해도 `TermsResponse` 전체 디코딩이 깨지지 않도록,
/// 알 수 없는 raw value는 실패시키지 않고 `.unknown`으로 흡수한다.
public enum TermType: RawRepresentable, Decodable, Sendable, Equatable {
    case service
    case privacy
    case unknown(String)

    public init(rawValue: String) {
        switch rawValue {
        case "SERVICE": self = .service
        case "PRIVACY": self = .privacy
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .service: return "SERVICE"
        case .privacy: return "PRIVACY"
        case .unknown(let value): return value
        }
    }
}

public struct TermsListItem: Decodable, Sendable {
    public let id: Int
    public let type: TermType
    public let documentUrl: String?

    public init(id: Int, type: TermType, documentUrl: String?) {
        self.id = id
        self.type = type
        self.documentUrl = documentUrl
    }
}
