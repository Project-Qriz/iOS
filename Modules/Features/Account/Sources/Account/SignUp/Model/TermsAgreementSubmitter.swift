//
//  TermsAgreementSubmitter.swift
//  QRIZ
//

/// 약관 동의 화면에서 사용자가 고른 동의 내용.
struct TermsAgreement: Equatable {
    let over14Confirmed: Bool
    let agreedTermIds: [Int]
}

/// 약관 동의 제출 실패 시 사용자에게 보여줄 내용.
/// `endsFlow`가 true면 알럿 확인 후 약관 화면을 닫는다(재시도해도 성공할 수 없는 경우).
struct TermsAgreementSubmissionError: Error, Equatable {
    let title: String
    let description: String?
    let endsFlow: Bool
}

/// "약관 동의하기"를 눌렀을 때의 처리 전략.
/// 이메일 가입은 동의 내용을 가입 플로우에 저장하고, 소셜 가입은 가입 API를 호출한다.
/// 실패는 `TermsAgreementSubmissionError`로 던져 화면에 그대로 노출한다.
@MainActor
protocol TermsAgreementSubmitter {
    func submit(_ agreement: TermsAgreement) async throws
}

/// 이메일 회원가입: 동의 내용을 `SignUpFlowViewModel`에 저장한다.
/// 실제 회원가입 API 호출은 플로우 마지막 단계(PasswordInputViewModel)에서 이루어진다.
@MainActor
struct SignUpFlowTermsSubmitter: TermsAgreementSubmitter {
    let signUpFlowViewModel: SignUpFlowViewModel
    let onTermsAgreed: () -> Void

    func submit(_ agreement: TermsAgreement) async {
        signUpFlowViewModel.updateOver14Confirmed(agreement.over14Confirmed)
        signUpFlowViewModel.updateAgreedTermIds(agreement.agreedTermIds)
        onTermsAgreed()
    }
}
