//
//  String+.swift
//  QRIZ
//
//  Created by 김세훈 on 12/29/24.
//

import Foundation

extension String {
    /// 아이디 유효성 체크 조건:
    /// 1. 길이: 6~20자
    /// 2. 영문과 숫자를 반드시 포함
    /// 3. 공백 불가
    /// 4. 특수문자 불포함
    var isValidId: Bool {
        let idRegex = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{6,20}$"
        return NSPredicate(format: "SELF MATCHES %@", idRegex).evaluate(with: self)
    }
    
    /// 비밀번호 유효성 체크 조건:
    /// 1. 길이: 8~16자
    /// 2. 최소 1개 이상의 대문자 포함
    /// 3. 최소 1개 이상의 소문자 포함
    /// 4. 최소 1개 이상의 숫자 포함
    /// 5. 최소 1개 이상의 특수문자 포함
    var isValidPassword: Bool {
        let passwordRegex = "^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%^&+=*!])(?=\\S+$).{8,16}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: self)
    }
    
    /// 이름 유효성 체크 조건:
    /// 1. 길이: 1~20자
    /// 2. 한글 또는 영문만 사용 가능
    var isValidName: Bool {
        let nameRegex = "^[a-zA-Z가-힣]{1,20}$"
        return NSPredicate(format: "SELF MATCHES %@", nameRegex).evaluate(with: self)
    }
    
    /// 이메일 유효성 체크 조건:
    /// 1. 이메일 아이디 부분: 영문 대소문자와 숫자만 허용, 최소 2자, 최대 10자
    /// 2. 도메인 이름 부분: 영문 대소문자와 숫자만 허용, 최소 2자, 최대 6자
    /// 3. 최상위 도메인 부분: 영문 대소문자만 허용, 최소 2자, 최대 3자 (예: com, net, org)
    var isValidEmail: Bool {
        let nameRegex = "^[a-zA-Z0-9]{2,10}@[a-zA-Z0-9]{2,6}\\.[a-zA-Z]{2,3}$"
        return NSPredicate(format: "SELF MATCHES %@", nameRegex).evaluate(with: self)
    }
}
