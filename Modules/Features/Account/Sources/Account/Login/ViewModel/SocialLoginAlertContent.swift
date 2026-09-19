//
//  SocialLoginAlertContent.swift
//  Account
//

import QRIZNetwork

/// 소셜 로그인 실패 에러를 사용자에게 보여줄 알럿 문구로 변환합니다.
struct SocialLoginAlertContent: Equatable {
    let title: String
    let description: String

    init(error: Error, providerName: String) {
        if Self.isEmailAlreadyExists(error) {
            self.title = "이미 가입된 이메일"
            self.description = "이미 다른 방법으로 가입된 이메일입니다.\n기존 로그인 방식으로 로그인해 주세요."
        } else {
            self.title = "\(providerName) 로그인 실패"
            self.description = "잠시 후 다시 시도해 주세요."
        }
    }

    private static func isEmailAlreadyExists(_ error: Error) -> Bool {
        guard case let NetworkError.clientError(httpStatus, _, _, reason, _) = error else {
            return false
        }
        return httpStatus == 409 && reason == "email_already_exists"
    }
}
