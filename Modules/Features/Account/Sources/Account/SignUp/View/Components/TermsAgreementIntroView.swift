//
//  TermsAgreementIntroView.swift
//  QRIZ
//

import SwiftUI
import DesignSystem

struct TermsAgreementIntroView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(uiImage: .appIconLogo)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 64, height: 64)

            (
                Text("Qriz").foregroundColor(Color.customBlue500)
                + Text(" 앱 이용을 위해\n필수 약관에 동의해주세요.").foregroundColor(Color.coolNeutral800)
            )
            .font(.system(size: 20, weight: .bold))
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}
