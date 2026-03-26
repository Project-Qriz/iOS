import Foundation
import UIKit
import Network
import QRIZUtils

final class MockSocialLoginService: SocialLoginService, @unchecked Sendable {

    enum MockError: Error { case notExpected }

    var logoutKakaoResult:  Result<Void, Error> = .success(())
    var logoutGoogleResult: Result<Void, Error> = .success(())
    var logoutAppleResult:  Result<Void, Error> = .success(())
    var unlinkKakaoResult:  Result<Void, Error> = .success(())

    func loginWithKakao() async throws -> SocialLoginResponse { throw MockError.notExpected }
    func loginWithGoogle(presenting: UIViewController) async throws -> SocialLoginResponse { throw MockError.notExpected }
    func loginWithApple(presenting: UIViewController) async throws -> SocialLoginResponse { throw MockError.notExpected }

    func logoutKakao() async throws  { try logoutKakaoResult.get() }
    func logoutGoogle() async throws { try logoutGoogleResult.get() }
    func logoutApple() async throws  { try logoutAppleResult.get() }
    func unlinkKakao() async throws  { try unlinkKakaoResult.get() }
}
