import Foundation
import QRIZNetwork
import QRIZUtils

@MainActor
final class MockMyPageService: MyPageService {

    var fetchVersionResult: Result<VersionResponse, Error> = .success(
        VersionResponse(
            code: 1,
            msg: "ok",
            data: VersionData(versionInfo: "1.0.0", updateInfo: "", date: "")
        )
    )

    var resetPlanResult: Result<DailyResetResponse, Error> = .success(
        DailyResetResponse(code: 1, msg: "초기화 완료!")
    )

    var deleteAccountResult: Result<DeleteAccountResponse, Error> = .success(
        DeleteAccountResponse(code: 0, msg: "ok")
    )

    var deleteSocialAccountResult: Result<SocialWithdrawResponse, Error> = .success(
        SocialWithdrawResponse(code: 0, msg: "ok")
    )

    func fetchVersion() async throws -> VersionResponse {
        try fetchVersionResult.get()
    }

    func resetPlan() async throws -> DailyResetResponse {
        try resetPlanResult.get()
    }

    func deleteAccount() async throws -> DeleteAccountResponse {
        try deleteAccountResult.get()
    }

    func deleteSocialAccount(socialLoginType: SocialLogin) async throws -> SocialWithdrawResponse {
        try deleteSocialAccountResult.get()
    }
}
