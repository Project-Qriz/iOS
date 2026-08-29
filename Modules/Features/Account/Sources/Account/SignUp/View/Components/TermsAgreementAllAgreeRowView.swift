//
//  TermsAgreementAllAgreeRowView.swift
//  QRIZ
//

import SwiftUI
import DesignSystem

struct TermsAgreementAllAgreeRowView: View {
    let isChecked: Bool
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Image(uiImage: isChecked ? .checkboxOnIcon : .checkboxOffIcon)
                .resizable()
                .frame(width: 24, height: 24)
                .onTapGesture(perform: onTap)

            Text("전체 동의")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color.coolNeutral800)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
        .background(Color.customBlue50)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.customBlue50, lineWidth: 1)
        )
    }
}
