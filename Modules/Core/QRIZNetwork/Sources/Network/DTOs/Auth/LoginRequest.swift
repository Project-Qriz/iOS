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

    public init(code: Int, msg: String, data: DataInfo) {
        self.code = code
        self.msg = msg
        self.data = data
    }

    public struct DataInfo: Decodable, Sendable {
        public let refreshToken: String?
        public let refreshExpiry: String?
        public let user: UserInfo
        public let reAgreementRequired: Bool?
        public let ageVerificationRequired: Bool?

        public init(
            refreshToken: String?, refreshExpiry: String?, user: UserInfo,
            reAgreementRequired: Bool? = nil, ageVerificationRequired: Bool? = nil
        ) {
            self.refreshToken = refreshToken
            self.refreshExpiry = refreshExpiry
            self.user = user
            self.reAgreementRequired = reAgreementRequired
            self.ageVerificationRequired = ageVerificationRequired
        }

        /// 서버가 두 플래그를 data 최상위/data.user 중 어디에 내려줄지 미확정이라 양쪽 다 방어적으로 확인한다.
        public var resolvedReAgreementRequired: Bool {
            reAgreementRequired ?? user.reAgreementRequired ?? false
        }

        public var resolvedAgeVerificationRequired: Bool {
            ageVerificationRequired ?? user.ageVerificationRequired ?? false
        }

        public var needsConsent: Bool {
            resolvedReAgreementRequired || resolvedAgeVerificationRequired
        }
    }
}
