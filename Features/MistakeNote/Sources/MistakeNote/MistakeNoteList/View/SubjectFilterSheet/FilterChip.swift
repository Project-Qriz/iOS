//
//  FilterChip.swift
//  MistakeNote
//
//  Created by Claude on 1/31/26.
//

import SwiftUI
import DesignSystem

public struct FilterChip: View {

    // MARK: - Properties

    public let title: String
    public let isSelected: Bool
    public let action: () -> Void

    // MARK: - Initializer

    public init(title: String, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.action = action
    }

    // MARK: - Body

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
            .foregroundColor(isSelected ? Color.customBlue500 : Color.coolNeutral800)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        isSelected ? Color.customBlue500 : Color.coolNeutral200,
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
