//
//  FindIDRequest.swift
//  QRIZ
//
//  Created by 김세훈 on 3/18/25.
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
     "msg": "입력하신 이메일로 아이디가 전송되었습니다.",
     "data": null
 }
 */

import Foundation

struct FindIDRequest: Request {
    typealias Response = FindIDResponse
    
    let path = "/api/find-username"
    let method: HTTPMethod = .post
    let email: String
    
    var query: QueryItems {
        ["email": email]
    }
    
    var headers: HTTPHeader {
        [HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue]
    }
}

struct FindIDResponse: Decodable {
    let code: Int
    let msg: String
}
