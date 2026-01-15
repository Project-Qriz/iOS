//
//  FilterChipButton.swift
//  QRIZ
//
//  Created by Claude on 1/15/26.
//

import SwiftUI

struct FilterChipButton: View {

    // MARK: - Properties

    let title: String
    let options: [String]
    @Binding var selectedOption: String
    @Binding var isExpanded: Bool

    // MARK: - Body

    var body: some View {
        chipButton
            .overlay(alignment: .topLeading) {
                if isExpanded {
                    dropdownMenu
                        .offset(y: 40)
                }
            }
            .zIndex(isExpanded ? 1 : 0)
            .animation(.easeInOut(duration: 0.2), value: isExpanded)
    }
}

// MARK: - Subviews

private extension FilterChipButton {

    var chipButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                isExpanded.toggle()
            }
        } label: {
            HStack(spacing: 4) {
                Text(selectedOption)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(uiColor: .coolNeutral500))

                Image(systemName: "chevron.down")
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(Color(uiColor: .coolNeutral500))
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .chipStyle()
        }
    }

    var dropdownMenu: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(options, id: \.self) { option in
                optionRow(for: option)
            }
        }
        .dropdownStyle()
    }

    func optionRow(for option: String) -> some View {
        let isSelected = selectedOption == option

        return Button {
            selectedOption = option
            withAnimation(.easeInOut(duration: 0.2)) {
                isExpanded = false
            }
        } label: {
            Text(option)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .foregroundColor(Color(uiColor: isSelected ? .customBlue500 : .coolNeutral800))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
        }
    }
}

// MARK: - ViewModifier

private extension View {

    func chipStyle() -> some View {
        self
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(uiColor: .coolNeutral200), lineWidth: 1)
            )
    }

    func dropdownStyle() -> some View {
        self
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(uiColor: .coolNeutral200), lineWidth: 1)
            )
            .shadow(
                color: Color(uiColor: .coolNeutral300).opacity(0.12),
                radius: 4,
                x: 0,
                y: 1
            )
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var selected1 = "모두"
        @State private var selected2 = "1과목"
        @State private var selected3 = "2과목"
        @State private var expanded1 = true
        @State private var expanded2 = false
        @State private var expanded3 = false

        var body: some View {
            HStack(spacing: 8) {
                FilterChipButton(
                    title: "모두",
                    options: ["모두", "오답만"],
                    selectedOption: $selected1,
                    isExpanded: $expanded1
                )

                FilterChipButton(
                    title: "1과목",
                    options: ["1과목", "오답만"],
                    selectedOption: $selected2,
                    isExpanded: $expanded2
                )

                FilterChipButton(
                    title: "2과목",
                    options: ["2과목", "오답만"],
                    selectedOption: $selected3,
                    isExpanded: $expanded3
                )

                Spacer()
            }
            .padding()
            .background(Color(uiColor: .systemGroupedBackground))
        }
    }

    return PreviewWrapper()
}
