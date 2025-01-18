//
//  FindAccountType.swift
//  QRIZ
//
//  Created by 김세훈 on 1/17/25.
//

import Foundation

enum FindAccountType {
    case findId
    case findPassword
    
    var headerTitle: String {
        switch self {
        case .findId:
            return "아이디를 잊으셨나요?"
        case .findPassword:
            return "비밀번호를 잊으셨나요?"
        }
    }
    
    var headerDescription: String {
        switch self {
        case .findId:
            return "Qriz에 가입했던 이메일을 입력하시면\n아이디를 메일로 보내드립니다."
        case .findPassword:
            return "기존에 가입할때 사용한 이메일을 입력하시면\n비밀번호 변경 메일을 전송해드립니다."
        }
    }
}
