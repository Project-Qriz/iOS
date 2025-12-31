//
//  ProblemOptionView.swift
//  QRIZ
//
//  Created by Claude on 12/30/25.
//

import SwiftUI

struct ProblemOptionView: View {
    
    let option: OptionData
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            indexCircle // 옵션 번호
            optionText // 옵션 텍스트
        }
        .padding(16)
        .background(optionBackgroundColor)
    }
}

// MARK: - Subviews

private extension ProblemOptionView {
    
    /// 옵션 번호 (1, 2, 3) 아이콘
    var indexCircle: some View {
        Text("\(option.number)")
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(numberTextColor)
            .frame(width: 40, height: 40)
            .background(numberBackgroundColor)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color(.coolNeutral700),
                            lineWidth: option.state == .normal ? 1 : 0)
            )
    }
    
    /// 옵션 본문 텍스트
    var optionText: some View {
        Text(option.text)
            .font(.system(size: 16))
            .foregroundColor(Color(.coolNeutral800))
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Color
private extension ProblemOptionView {
    
    var numberTextColor: Color {
        option.state == .normal ? .black : .white
    }

    var numberBackgroundColor: Color {
        switch option.state {
        case .normal:    return .white
        case .correct:   return Color(.customBlue500)
        case .incorrect: return Color(.customRed500)
        }
    }

    var optionBackgroundColor: Color {
        switch option.state {
        case .normal:    return .white
        case .correct:   return Color(.customBlue500).opacity(0.14)
        case .incorrect: return Color(.customRed500).opacity(0.14)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 12) {
        ProblemOptionView(
            option: OptionData(
                number: 1,
                text: "SELECT * FROM table WHERE id = 1;",
                state: .normal
            )
        )
        
        ProblemOptionView(
            option: OptionData(
                number: 2,
                text: "SELECT * FROM table WHERE id = 2;",
                state: .correct
            )
        )
        
        ProblemOptionView(
            option: OptionData(
                number: 3,
                text: "SELECT * FROM table WHERE id = 3;",
                state: .incorrect
            )
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
