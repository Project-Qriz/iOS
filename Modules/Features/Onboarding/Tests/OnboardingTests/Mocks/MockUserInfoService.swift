import Foundation
import QRIZNetwork
import QRIZUtils

// @MainActor: UserInfoService는 Sendable을 요구하며, Swift 5.7+에서 @MainActor 클래스는
// 단일 액터에 격리되어 암묵적으로 Sendable을 만족한다.
@MainActor
final class MockUserInfoService: UserInfoService {
    var getUserInfoResult: Result<UserInfoResponse, Error> = .success(.stub())

    func getUserInfo() async throws -> UserInfoResponse {
        try getUserInfoResult.get()
    }
}
