//
//  FilterChip.swift
//  QRIZ
//
//  Created by Claude on 1/31/26.
//

import SwiftUI

struct FilterChip: View {

    // MARK: - Properties

    let title: String
    let isSelected: Bool
    let action: () -> Void

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
            .foregroundColor(isSelected ? Color(uiColor: .customBlue500) : Color(uiColor: .coolNeutral800))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        isSelected ? Color(uiColor: .customBlue500) : Color(uiColor: .coolNeutral200),
                        lineWidth: 1
                    )
            )
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        HStack(spacing: 8) {
            FilterChip(title: "SELECT 문", isSelected: true) {}
            FilterChip(title: "SELECT 문", isSelected: false) {}
        }

        HStack(spacing: 8) {
            FilterChip(title: "관계형 데이터베이스 개요", isSelected: true) {}
            FilterChip(title: "관계형 데이터베이스 개요", isSelected: false) {}
        }
    }
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}
