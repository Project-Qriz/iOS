//
//  ClipDetailRequest.swift
//  QRIZ
//
//  Created by Claude on 1/28/26.
//

/// 오답노트 문제 상세 조회
/// GET /api/v1/clips/{clipId}/detail
public struct ClipDetailRequest: Request, Sendable {
    public typealias Response = ClipDetailResponse

    public let method: HTTPMethod = .get
    private let accessToken: String
    private let clipId: Int

    public var path: String { "/api/v1/clips/\(clipId)/detail" }

    public var headers: HTTPHeader {
        [
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }

    public init(accessToken: String, clipId: Int) {
        self.accessToken = accessToken
        self.clipId = clipId
    }
}

public struct ClipDetailResponse: Decodable, Sendable {
    public let code: Int
    public let msg: String
    public let data: DailyResultDetail

    public init(code: Int, msg: String, data: DailyResultDetail) {
        self.code = code
        self.msg = msg
        self.data = data
    }
}
