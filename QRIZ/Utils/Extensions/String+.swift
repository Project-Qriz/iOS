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
    
    /// 1. 최소 1개 이상의 대문자 포함
    /// 2. 최소 1개 이상의 소문자 포함
    /// 3. 최소 1개 이상의 숫자 포함
    /// 4. 최소 1개 이상의 특수문자 포함
    var isValidCharacterRequirement: Bool {
        let characterRegex = "^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%^&+=*!]).*$"
        return NSPredicate(format: "SELF MATCHES %@", characterRegex).evaluate(with: self)
    }
    
    /// 1. 길이: 8~16자
    var isValidLengthRequirement: Bool {
        let lengthRegex = "^\\S{8,16}$"
        return NSPredicate(format: "SELF MATCHES %@", lengthRegex).evaluate(with: self)
    }
    
    /// 비밀번호 유효성 체크 조건:
    /// 1. 길이: 8~16자
    /// 2. 최소 1개 이상의 대문자 포함
    /// 3. 최소 1개 이상의 소문자 포함
    /// 4. 최소 1개 이상의 숫자 포함
    /// 5. 최소 1개 이상의 특수문자 포함
    var isValidPassword: Bool {
        return isValidCharacterRequirement && isValidLengthRequirement
    }
    
    /// 이름 유효성 체크 조건:
    /// 1. 길이: 1~20자
    /// 2. 한글 또는 영문만 사용 가능
    var isValidName: Bool {
        let nameRegex = "^[a-zA-Z가-힣]{1,20}$"
        return NSPredicate(format: "SELF MATCHES %@", nameRegex).evaluate(with: self)
    }
    
    /// 이메일 유효성 체크 조건:
    /// 1. 로컬 파트 ("@" 앞부분): 영문 대소문자, 숫자, ._%+- 허용, 2~64자
    /// 2. 도메인 파트 ("@" 중간부분): 영문 대소문자, 숫자, .- 허용, 2~255자
    /// 3. 최상위 도메인 파트 (마지막 "." 이후): 영문 대소문자 허용, 2~10자
    var isValidEmail: Bool {
        let emailRegex = "^[a-zA-Z0-9._%+-]{2,64}@[a-zA-Z0-9.-]{2,255}\\.[a-zA-Z]{2,10}$"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }
}
