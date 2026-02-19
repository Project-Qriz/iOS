//
//  EmailSendRequest.swift
//  QRIZ
//
//  Created by 김세훈 on 3/4/25.
//

import Foundation

// 성공
//{
//    "code": 1,
//    "msg": "이메일 전송이 요청되었습니다.",
//    "data": "인증번호가 발송되었습니다."
//}
// 실패
//{
//    "timestamp": "2025-03-04T06:58:21.717+00:00",
//    "status": 400,
//    "error": "Bad Request",
//    "path": "/api/email-send"
//}

public struct EmailSendRequest: Request , Sendable {
    public typealias Response = EmailSendResponse
    
    public let path = "/api/email-send"
    public let method: HTTPMethod = .post
    public let email: String
    
    public var body: Encodable? {
        ["email": email]
    }
    
    public var headers: HTTPHeader {
        [HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue]
    }
}

public struct EmailSendResponse: Decodable , Sendable {
    public let code: Int
    public let msg: String
    public let data: String
}
