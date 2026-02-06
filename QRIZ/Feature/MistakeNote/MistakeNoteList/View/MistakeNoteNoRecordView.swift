//
//  MistakeNoteNoRecordView.swift
//  QRIZ
//
//  Created by Claude on 2/5/26.
//

import SwiftUI

struct MistakeNoteNoRecordView: View {

    // MARK: - Properties

    var onGoToExam: (() -> Void)?

    // MARK: - Body

    var body: some View {
        VStack(spacing: 12) {
            Image("splashLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)

            VStack(spacing: 4) {
                Text("시험을 본 기록이 없습니다.")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(uiColor: .coolNeutral800))

                Text("오답노트를 만들고 싶다면 테스트를 해봐요!")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(uiColor: .coolNeutral500))
                    .multilineTextAlignment(.center)
            }

            goToExamButton
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, UIScreen.main.bounds.height * 0.2)
    }

    // MARK: - Subviews

    private var goToExamButton: some View {
        Button {
            onGoToExam?()
        } label: {
            Text("시험 보러가기")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color(uiColor: .customBlue500))
                .cornerRadius(8)
        }
        .padding(.horizontal, 69)
    }
}

// MARK: - Preview

#Preview {
    MistakeNoteNoRecordView()
        .background(Color.white)
}
