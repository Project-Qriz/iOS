//
//  LoginRequest.swift
//  QRIZ
//
//  Created by 김세훈 on 3/26/25.
//

/*
 실패
 
 {
     "code": -1,
     "msg": "로그인실패",
     "data": null
 }
 
 성공
 
 {
     "code": 1,
     "msg": "로그인성공",
     "data": {
         "id": 5,
         "username": "hun12345",
         "nickname": "훈",
         "createdAt": "2025-03-18 17:03:54",
         "previewTestStatus": "NOT_STARTED"
     }
 }
 */

import Foundation

struct LoginRequest: Request {
    typealias Response = LoginResponse
    
    let path = "/api/login"
    let method: HTTPMethod = .post
    let id: String
    let password: String
    
    var body: Encodable? {
        [
            "username": id,
            "password": password
        ]
    }
    
    var headers: HTTPHeader {
        [HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue]
    }
}

struct LoginResponse: Decodable {
    let code: Int
    let msg: String
    let data: DataInfo
    
    struct DataInfo: Decodable {
        let refreshToken: String?
        let refreshExpiry: String?
        let user: UserInfo
    }
}
