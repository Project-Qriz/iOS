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
public struct LoginRequest: Request, Sendable {
    public typealias Response = LoginResponse
    
    public let path = "/api/login"
    public let method: HTTPMethod = .post
    public let id: String
    public let password: String
    
    public var body: Encodable? {
        [
            "username": id,
            "password": password
        ]
    }
    
    public var headers: HTTPHeader {
        [HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue]
    }
}

public struct LoginResponse: Decodable, Sendable {
    public let code: Int
    public let msg: String
    public let data: DataInfo
    
    public struct DataInfo: Decodable, Sendable {
        public let refreshToken: String?
        public let refreshExpiry: String?
        public let user: UserInfo
    }
}
