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

struct EmailSendRequest: Request {
    typealias Response = EmailSendResponse
    
    let path = "/api/email-send"
    let method: HTTPMethod = .post
    let email: String
    
    var body: Encodable? {
        ["email": email]
    }
    
    var headers: HTTPHeader {
        [HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue]
    }
}

struct EmailSendResponse: Decodable {
    let code: Int
    let msg: String
    let data: String
}
