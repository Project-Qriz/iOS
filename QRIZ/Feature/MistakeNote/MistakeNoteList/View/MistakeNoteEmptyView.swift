//
//  MistakeNoteEmptyView.swift
//  QRIZ
//
//  Created by Claude on 2/4/26.
//

import SwiftUI

struct MistakeNoteEmptyView: View {

    // MARK: - Body

    var body: some View {
        VStack(spacing: 12) {
            Image("splashLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)

            Text("앗, 훌륭한 실력 탓에 오답이 없네요!")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(uiColor: .coolNeutral800))

            Text("다른 회차를 선택하거나\n필터 안 '모두'를 선택하여 전환해보세요.")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color(uiColor: .coolNeutral500))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, UIScreen.main.bounds.height * 0.2)
    }
}

// MARK: - Preview

#Preview {
    MistakeNoteEmptyView()
        .background(Color(uiColor: .white))
}
