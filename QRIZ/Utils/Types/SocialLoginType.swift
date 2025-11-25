//
//  SocialLoginType.swift
//  QRIZ
//
//  Created by 김세훈 on 9/1/25.
//

import Foundation

enum SocialLogin: String {
    case google = "google"
    case kakao = "kakao"
    case apple = "apple"
    case email
    
    var logoName: String {
        switch self {
        case .google: return "googleLogo"
        case .kakao: return "kakaoLogo"
        case .apple: return "appleLogo"
        case .email: return ""
        }
    }
    
    init(from raw: String?) {
        guard let value = raw?.lowercased() else {
            self = .email
            return
        }
        self = SocialLogin(rawValue: value) ?? .email
    }
    
    var codeKey: String {
        switch self {
        case .google, .apple: return "serverAuthCode"
        default: return "authCode"
        }
    }
}
