//
//  TermsAgreementHeaderView.swift
//  QRIZ
//

import SwiftUI
import DesignSystem

struct TermsAgreementHeaderView: View {
    let progress: Double
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
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
            .padding(.horizontal, 32)
            .padding(.top, 24)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle().fill(Color.coolNeutral100)
                    Rectangle()
                        .fill(Color.customBlue500)
                        .frame(width: geometry.size.width * max(0, min(progress, 1)))
                }
            }
            .frame(height: 4)
            .padding(.top, 16)
        }
    }
}
