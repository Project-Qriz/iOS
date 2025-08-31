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
    
    var logoName: String {
        switch self {
        case .google: return "googleLogo"
        case .kakao:  return "kakaoLogo"
        case .apple:  return "appleLogo"
        }
    }
}
