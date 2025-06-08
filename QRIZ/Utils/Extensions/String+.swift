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
    /// 1. 이메일 아이디 부분: 영문 대소문자와 숫자만 허용, 최소 2자, 최대 10자
    /// 2. 도메인 이름 부분: 영문 대소문자와 숫자만 허용, 최소 2자, 최대 6자
    /// 3. 최상위 도메인 부분: 영문 대소문자만 허용, 최소 2자, 최대 3자 (예: com, net, org)
    var isValidEmail: Bool {
        let nameRegex = "^[a-zA-Z0-9]{2,10}@[a-zA-Z0-9]{2,6}\\.[a-zA-Z]{2,3}$"
        return NSPredicate(format: "SELF MATCHES %@", nameRegex).evaluate(with: self)
    }
}

extension String {
    /// 모의고사 점수변동 그래프 Date
    var graphDate: Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd"
        guard let date = dateFormatter.date(from: self) else {
            print("Failed to convert from String to GraphDate")
            return Date()
        }
        return date
    }
    
    /// 월·일 형식의 문자열을 받아 오늘을 기준으로 해당 남짜와의 일수 차이를 계산해주는 프로퍼티입니다.
    /// - Format: `"M월 d일(요일)"` (예: `"3월 8일(토)"`)
    var dDay: Int {
        let trimmed = split(separator: "(").first.map(String.init) ?? self
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = "M월 d일"
        
        guard let mdDate = formatter.date(from: trimmed) else { return 0 }
        
        var comps = Calendar.current.dateComponents([.year], from: Date())
        let mdComps = Calendar.current.dateComponents([.month, .day], from: mdDate)
        comps.month = mdComps.month
        comps.day   = mdComps.day
        comps.calendar = Calendar.current
        comps.timeZone = TimeZone(identifier: "Asia/Seoul")
        
        guard let target = comps.date else { return 0 }
        
        let today = Calendar.current.startOfDay(for: Date())
        return Calendar.current.dateComponents([.day], from: today, to: target).day ?? 0
    }
}
