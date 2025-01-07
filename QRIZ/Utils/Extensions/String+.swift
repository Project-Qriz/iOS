//
//  String+.swift
//  QRIZ
//
//  Created by 김세훈 on 12/29/24.
//

import Foundation

extension String {
    /// 아이디 유효성 체크 (8~30자 + 영문 + 숫자만 가능)
    var isValidID: Bool {
        let idRegex = "^[A-Za-z0-9]{8,30}$"
        return NSPredicate(format: "SELF MATCHES %@", idRegex).evaluate(with: self)
    }
    
    /// 비밀번호 유효성 체크 (8~30자 + 영문 대소문자, 숫자, 특수문자만 가능)
    var isValidPassword: Bool {
        let passwordRegex = "^[A-Za-z0-9!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>/?]{8,30}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: self)
    }
    
    /// 이름 유효성 체크 (1~20자 + 한글/영문만 가능)
    var isValidName: Bool {
        let nameRegex = "^[가-힣A-Za-z]{1,20}$"
        return NSPredicate(format: "SELF MATCHES %@", nameRegex).evaluate(with: self)
    }
}
