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

public struct PasswordResetRequest: Request, Sendable {
    public typealias Response = PasswordResetResponse
    
    public let path = "/api/pwd-reset"
    public let method: HTTPMethod = .post
    public let password: String
    public let resetToken: String
    
    public var body: Encodable? {
        [
            "newPassword": password,
            "resetToken": resetToken
        ]
    }
    
    public var headers: HTTPHeader {
        [HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue]
    }
}

public struct PasswordResetResponse: Decodable, Sendable {
    public let code: Int
    public let msg: String
    public let data: DataInfo?

    public init(code: Int, msg: String, data: DataInfo? = nil) {
        self.code = code
        self.msg = msg
        self.data = data
    }

    public struct DataInfo: Decodable, Sendable {
        public let username: String
        public let password: String

        public init(username: String, password: String) {
            self.username = username
            self.password = password
        }
    }
}
