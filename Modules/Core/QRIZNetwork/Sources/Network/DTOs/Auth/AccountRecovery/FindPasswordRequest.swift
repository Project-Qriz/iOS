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

public struct FindPasswordRequest: Request, Sendable {
    public typealias Response = FindPasswordResponse
    
    public let path = "/api/find-pwd"
    public let method: HTTPMethod = .post
    public let email: String
    
    public var body: Encodable? {
        ["email": email]
    }
    
    public var headers: HTTPHeader {
        [HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue]
    }
}

public struct FindPasswordResponse: Decodable, Sendable {
    public let code: Int
    public let msg: String

    public init(code: Int, msg: String) {
        self.code = code
        self.msg = msg
    }
}
