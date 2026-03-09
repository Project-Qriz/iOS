//
//  SocialLoginService.swift
//  Network
//

import UIKit

public protocol SocialLoginService: Sendable {

    func loginWithKakao() async throws -> SocialLoginResponse

    func logoutKakao() async throws

    func unlinkKakao() async throws

    func loginWithGoogle(presenting: UIViewController) async throws -> SocialLoginResponse

    func logoutGoogle() async throws

    func loginWithApple(presenting: UIViewController) async throws -> SocialLoginResponse

    func logoutApple() async throws
}
