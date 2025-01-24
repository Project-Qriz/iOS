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
            return "이메일로 아이디를 전송해 드릴게요."
        case .findPassword:
            return "비밀번호를 잊으셨나요?"
        }
    }
    
    var headerDescription: String {
        switch self {
        case .findId:
            return "가입했던 이메일을 입력하고\n'아이디 찾기' 버튼을 눌러주세요."
        case .findPassword:
            return "이메일로 인증과정을 거친 후,\n재설정 할 수 있도록 도와드릴게요."
        }
    }
}
