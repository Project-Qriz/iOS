//
//  UserInfoRequest.swift
//  QRIZ
//
//  Created by ch on 4/24/25.
//

/*
 <<일반 로그인>> => 소셜 로그인 시, provider에 "KAKAO", "GOOGLE" 로 전송됨.
 
 case 1) 설문조사 실시하지 않음
 
 {
     "code": 1,
     "msg": "사용자 정보 불러오기 성공",
     "data": {
         "name": "채영",
         "userId": "userId0212",
         "email": "email@naver.com",
         "previewTestStatus": "NOT_STARTED",
         "provider": null
     }
 }
 
 case 2) 설문조사에서 아무것도 몰라요 선택
 {
     "code": 1,
     "msg": "사용자 정보 불러오기 성공",
     "data": {
         "name": "채영",
         "userId": "userId0212",
         "email": "email@naver.com",
         "previewTestStatus": "PREVIEW_SKIPPED",
         "provider": null
     }
 }
 
 case 3) 설문조사에서 선택한 개념이 존재 + 프리뷰 테스트 실시하지 않음
 {
     "code": 1,
     "msg": "사용자 정보 불러오기 성공",
     "data": {
         "name": "채영",
         "userId": "userId0212",
         "email": "email@naver.com",
         "previewTestStatus": "SURVEY_COMPLETED",
         "provider": null
     }
 }
 
 case 4) 프리뷰 테스트 완료
 {
     "code": 1,
     "msg": "사용자 정보 불러오기 성공",
     "data": {
         "name": "채영",
         "userId": "userId0212",
         "email": "email@naver.com",
         "previewTestStatus": "PREVIEW_COMPLETED",
         "provider": null
     }
 }
 */

import Foundation

struct UserInfoRequest: Request {
    
    // MARK: - Properties
    typealias Response = UserInfoResponse

    let path = "/api/v1/user/info"
    let method: HTTPMethod = .get
    private let accessToken: String
    
    var headers: HTTPHeader {
        return [HTTPHeaderField.authorization.rawValue: accessToken]
    }
    
    // MARK: - Initializers
    init(accessToken: String) {
        self.accessToken = accessToken
    }
}

struct UserInfoResponse: Decodable {
    let code: Int
    let msg: String
    let data: UserInfo
}

struct UserInfo: Decodable {
    let name: String
    let userId: String
    let email: String
    let previewTestStatus: PreviewTestStatus
    let provider: String?
}
