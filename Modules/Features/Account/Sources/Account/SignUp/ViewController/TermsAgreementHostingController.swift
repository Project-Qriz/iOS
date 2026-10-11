//
//  TermsAgreementHostingController.swift
//  QRIZ
//

import SwiftUI

/// 약관동의 화면은 가입 push 스택의 첫 화면으로, 자체 헤더에 X 버튼을 두고 시스템 내비게이션 바는 숨긴다.
/// 이후 화면(이메일 인증 등)은 기본 내비게이션 바를 그대로 사용하므로, 숨김 처리는 이 화면이 보이는 동안만 적용한다.
final class TermsAgreementHostingController: UIHostingController<TermsAgreementView> {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}
