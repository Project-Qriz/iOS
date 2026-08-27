//
//  TermsAgreementHeaderView.swift
//  QRIZ
//

import SwiftUI
import DesignSystem

struct TermsAgreementHeaderView: View {
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Text("약관동의")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color.coolNeutral800)

            HStack {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .foregroundColor(Color.coolNeutral800)
                        .frame(width: 24, height: 24)
                }
                Spacer()
            }
        }
    }
}
