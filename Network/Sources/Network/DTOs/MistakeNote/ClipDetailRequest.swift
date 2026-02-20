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

    public let accessToken: String
    public let clipId: Int

    public var path: String { "/api/v1/clips/\(clipId)/detail" }
    public let method: HTTPMethod = .get

    public var headers: HTTPHeader {
        [
            HTTPHeaderField.authorization.rawValue: accessToken
        ]
    }
}

// MARK: - Response

public struct ClipDetailResponse: Decodable, Sendable {
    public let code: Int
    public let msg: String
    public let data: DailyResultDetail
}
