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
    let isAllChip: Bool
    let action: () -> Void

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .semibold))
                }

                Text(title)
                    .font(.system(size: 12, weight: isSelected ? .bold : .medium))
            }
            .foregroundColor(Color(uiColor: .coolNeutral800))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white)
            .cornerRadius(9)
            .overlay(
                RoundedRectangle(cornerRadius: 9)
                    .stroke(
                        isSelected ? Color(uiColor: .coolNeutral800) : Color(uiColor: .coolNeutral200),
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
            FilterChip(title: "전체", isSelected: true, isAllChip: true) {}
            FilterChip(title: "전체", isSelected: false, isAllChip: true) {}
        }

        HStack(spacing: 8) {
            FilterChip(title: "SELECT 문", isSelected: true, isAllChip: false) {}
            FilterChip(title: "SELECT 문", isSelected: false, isAllChip: false) {}
        }
    }
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}
