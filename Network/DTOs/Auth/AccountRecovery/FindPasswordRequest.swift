//
//  FindPasswordRequest.swift
//  QRIZ
//
//  Created by 김세훈 on 3/19/25.
//

/*
 실패
 
 {
     "code": -1,
     "msg": "해당 이메일로 등록된 계정이 없습니다.",
     "data": null
 }
 
 성공
 
 {
     "code": 1,
     "msg": "비밀번호 재설정 인증번호가 이메일로 발송되었습니다.",
     "data": null
 }
 */

import Foundation

struct FindPasswordRequest: Request {
    typealias Response = FindPasswordResponse
    
    let path = "/api/find-pwd"
    let method: HTTPMethod = .post
    let email: String
    
    var body: Encodable? {
        ["email": email]
    }
    
    var headers: HTTPHeader {
        [HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue]
    }
}

struct FindPasswordResponse: Decodable {
    let code: Int
    let msg: String
}
