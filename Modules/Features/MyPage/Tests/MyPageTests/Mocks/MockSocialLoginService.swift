import Foundation
import UIKit
import QRIZNetwork
import QRIZUtils

@MainActor
final class MockSocialLoginService: SocialLoginService {

    enum MockError: Error { case notExpected }

    var logoutKakaoResult:  Result<Void, Error> = .success(())
    var logoutGoogleResult: Result<Void, Error> = .success(())
    var logoutAppleResult:  Result<Void, Error> = .success(())
    var unlinkKakaoResult:  Result<Void, Error> = .success(())
    private(set) var unlinkKakaoCallCount = 0

    func loginWithKakao() async throws -> SocialLoginResponse { throw MockError.notExpected }
    func loginWithGoogle(presenting: UIViewController) async throws -> SocialLoginResponse { throw MockError.notExpected }
    func loginWithApple(presenting: UIViewController) async throws -> SocialLoginResponse { throw MockError.notExpected }

    func logoutKakao() async throws  { try logoutKakaoResult.get() }
    func logoutGoogle() async throws { try logoutGoogleResult.get() }
    func logoutApple() async throws  { try logoutAppleResult.get() }
    func unlinkKakao() async throws  {
        unlinkKakaoCallCount += 1
        try unlinkKakaoResult.get()
    }
}
