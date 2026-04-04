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

public struct FindIDRequest: Request, Sendable {
    public typealias Response = FindIDResponse
    
    public let path = "/api/find-username"
    public let method: HTTPMethod = .post
    public let email: String
    
    public var body: Encodable? {
        ["email": email]
    }
    
    public var headers: HTTPHeader {
        [HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue]
    }
}

public struct FindIDResponse: Decodable, Sendable {
    public let code: Int
    public let msg: String
}
