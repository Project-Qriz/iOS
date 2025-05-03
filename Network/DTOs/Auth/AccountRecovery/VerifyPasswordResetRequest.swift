//
//  VerifyPasswordResetRequest.swift
//  QRIZ
//
//  Created by 김세훈 on 3/19/25.
//

/*
 실패
 
 {
     "code": -1,
     "msg": "인증번호가 유효하지 않거나 만료되었습니다",
     "data": null
 }
 
 성공
 
 {
     "code": 1,
     "msg": "인증이 완료되었습니다",
     "data": null
 }
 */

import Foundation

struct VerifyPasswordResetRequest: Request {
    typealias Response = VerifyPasswordResetResponse
    
    let path = "/api/verify-pwd-reset"
    let method: HTTPMethod = .post
    let email: String
    let authNumber: String
    
    var body: Encodable? {
        [
            "email": email,
            "authNumber": authNumber
        ]
    }
    
    var headers: HTTPHeader {
        [HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue]
    }
}

struct VerifyPasswordResetResponse: Decodable {
    let code: Int
    let msg: String
}
