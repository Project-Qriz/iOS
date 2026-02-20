//
//  JoinRequest.swift
//  QRIZ
//
//  Created by 김세훈 on 3/12/25.
//

import Foundation


/*
 2025년 03월 12일 이메일 중복 (가입된 이메일인지 확인하는 api 분기 처리 전 로직)
 
 1. 유효성 모두 실패한 케이스 (400)
 password는 왜 정규식을 반환을 하는건가?
 username의 유효성은 6글자 이상인데 2~20글자로 표시됨
 
 {
 "code": -1,
 "msg": "유효성 검사 실패",
 "data": {
 "password": "must match \"^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%^&+=*!])(?=\\S+$).{8,16}$\"",
 "nickname": "한글/영문 1~20자 이내로 작성해주세요",
 "email": "올바른 이메일 형식을 입력해주세요.",
 "username": "영문/숫자 2~20자 이내로 작성해주세요"
 }
 }
 
 2. 동일한 username(아이디)이 존재하는 경우 (400)
 
 {
 "code": -1,
 "msg": "동일한 username이 존재합니다.",
 "data": null
 }
 
 3. 동일한 email이 존재하는 경우 (400)
 
 {
 "code": -1,
 "msg": "이미 가입된 이메일입니다.",
 "data": null
 }
 
 4. 성공 케이스(200)
 
 {
 "code": 1,
 "msg": "회원가입 성공",
 "data": {
 "id": 2,
 "username": "asdf2221",
 "nickname": "ksh"
 }
 }
 
 */

public struct JoinRequest: Request, Sendable {
    public typealias Response = JoinResponse
    
    public let path = "/api/join"
    public let method: HTTPMethod = .post
    public let username: String
    public let password: String
    public let nickname: String
    public let email: String
    
    public var body: Encodable? {
        [
            "username": username,
            "password": password,
            "nickname": nickname,
            "email": email
        ]
    }
    
    public var headers: HTTPHeader {
        [HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue]
    }
}

public enum JoinResponse: Sendable {
    case success(JoinResponseSuccess)
    case failure(JoinResponseFailure)
}

extension JoinResponse: Decodable {
    public enum CodingKeys: String, CodingKey, Sendable {
        case code
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let code = try container.decode(Int.self, forKey: .code)

        if code == 1 {
            let successValue = try JoinResponseSuccess(from: decoder)
            self = .success(successValue)
        } else {
            let failureValue = try JoinResponseFailure(from: decoder)
            self = .failure(failureValue)
        }
    }
}

public struct JoinResponseSuccess: Decodable, Sendable {
    public let code: Int
    public let msg: String
    public let data: SuccessData
    
    public struct SuccessData: Decodable, Sendable {
        public let id: Int
        public let username: String
        public let nickname: String
    }
}

public struct JoinResponseFailure: Decodable, Sendable {
    public let code: Int
    public let msg: String
    public let data: FailureData?
    
    /// 실패 상황에 따라 data가 null이거나, 유효성 에러 정보를 담을 수 있으므로 옵셔널
    public struct FailureData: Decodable, Sendable {
        // 유효성 에러일 경우 아래 필드에 구체적인 에러 메시지
        public let password: String?
        public let nickname: String?
        public let email: String?
        public let username: String?
    }
}
