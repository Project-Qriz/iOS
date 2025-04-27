//
//  PasswordResetRequest.swift
//  QRIZ
//
//  Created by 김세훈 on 3/19/25.
//

/*
 실패
 
 {
     "code": -1,
     "msg": "해당 계정이 존재하지 않습니다. 아이디 혹은 이메일을 확인해주세요."
     "data": {
         null
     }
 }
 
 성공
 
 {
     "code": 1,
     "msg": "비밀번호 변경 성공"
     "data": {
         "username": "String", // 아이디
         "password": "EDoip123214215214" // BCrptPasswordEncoder 로 변형
     }
 }
 */

import Foundation

struct PasswordResetRequest: Request {
    typealias Response = PasswordResetResponse
    
    let path = "/api/pwd-reset"
    let method: HTTPMethod = .post
    let password: String
    
    var body: Encodable? {
        ["password": password]
    }
    
    var headers: HTTPHeader {
        [HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue]
    }
}

struct PasswordResetResponse: Decodable {
    let code: Int
    let msg: String
    let data: DataInfo?
    
    struct DataInfo: Decodable {
        let username: String
        let password: String
    }
}

