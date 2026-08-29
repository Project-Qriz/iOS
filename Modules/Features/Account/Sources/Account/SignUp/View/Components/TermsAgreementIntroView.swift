//
//  TermsAgreementIntroView.swift
//  QRIZ
//

import SwiftUI
import DesignSystem

struct TermsAgreementIntroView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(uiImage: .appIconLogo)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)

            (
                Text("Qriz").foregroundColor(Color.customBlue500)
                + Text(" 앱 이용을 위해\n필수 약관에 동의해주세요.").foregroundColor(Color.coolNeutral800)
            )
            .font(.system(size: 24, weight: .bold))
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}
