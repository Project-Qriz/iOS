//
//  SocialAuthError.swift
//  Auth
//

/// 소셜 로그인 공통 에러 타입입니다.
/// SDK별 에러를 외부에 노출하지 않고 공통 타입으로 변환합니다.
public enum SocialAuthError: Error, Equatable {
    case cancelled
}
