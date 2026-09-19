//
//  SocialLoginAlertContentTests.swift
//  AccountTests
//

import Testing
@testable import Account
import QRIZNetwork

@Suite("SocialLoginAlertContent 테스트")
struct SocialLoginAlertContentTests {

    private func emailConflict(
        httpStatus: Int = 409,
        reason: String? = "email_already_exists"
    ) -> NetworkError {
        .clientError(
            httpStatus: httpStatus,
            serverCode: -1,
            message: "이미 가입된 이메일",
            reason: reason,
            detailCode: 2002
        )
    }

    @Test("409 + email_already_exists → 이메일 중복 전용 안내")
    func emailAlreadyExistsShowsDedicatedContent() {
        let content = SocialLoginAlertContent(error: emailConflict(), providerName: "카카오")

        #expect(content.title == "이미 가입된 이메일")
        #expect(content.description == "이미 다른 방법으로 가입된 이메일입니다.\n기존 로그인 방식으로 로그인해 주세요.")
    }

    @Test("이메일 중복 안내는 provider 이름과 무관하다", arguments: ["카카오", "구글", "애플"])
    func emailAlreadyExistsIsProviderIndependent(providerName: String) {
        let content = SocialLoginAlertContent(error: emailConflict(), providerName: providerName)

        #expect(content.title == "이미 가입된 이메일")
    }

    @Test("409지만 reason이 다르면 기본 실패 안내")
    func conflictWithOtherReasonFallsBack() {
        let content = SocialLoginAlertContent(
            error: emailConflict(reason: "something_else"),
            providerName: "카카오"
        )

        #expect(content.title == "카카오 로그인 실패")
        #expect(content.description == "잠시 후 다시 시도해 주세요.")
    }

    @Test("reason이 nil이면 기본 실패 안내")
    func nilReasonFallsBack() {
        let content = SocialLoginAlertContent(error: emailConflict(reason: nil), providerName: "구글")

        #expect(content.title == "구글 로그인 실패")
    }

    @Test("reason이 email_already_exists여도 409가 아니면 기본 실패 안내")
    func otherStatusWithSameReasonFallsBack() {
        let content = SocialLoginAlertContent(error: emailConflict(httpStatus: 400), providerName: "애플")

        #expect(content.title == "애플 로그인 실패")
    }

    @Test("서버 에러 → 기본 실패 안내")
    func serverErrorFallsBack() {
        let content = SocialLoginAlertContent(
            error: NetworkError.serverError(httpStatus: 500),
            providerName: "카카오"
        )

        #expect(content.title == "카카오 로그인 실패")
        #expect(content.description == "잠시 후 다시 시도해 주세요.")
    }

    @Test("NetworkError가 아닌 에러 → 기본 실패 안내")
    func unknownErrorFallsBack() {
        struct AnyError: Error {}

        let content = SocialLoginAlertContent(error: AnyError(), providerName: "카카오")

        #expect(content.title == "카카오 로그인 실패")
    }
}
