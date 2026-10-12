//
//  SocialLoginService.swift
//  Network
//

import UIKit

public protocol SocialLoginService: Sendable {

    func loginWithKakao() async throws -> SocialLoginResult

    func logoutKakao() async throws

    func unlinkKakao() async throws

    func loginWithGoogle(presenting: UIViewController) async throws -> SocialLoginResult

    func logoutGoogle() async throws

    func loginWithApple(presenting: UIViewController) async throws -> SocialLoginResult

    func logoutApple() async throws
}
