//
//  DaySelectDropdownButton.swift
//  MistakeNote
//
//  Created by Claude on 1/13/26.
//

import SwiftUI
import DesignSystem

public struct DaySelectDropdownButton: View {

    // MARK: - Properties

    public let days: [String]
    @Binding public var selectedDay: String
    @Binding public var isExpanded: Bool

    private var hasRecords: Bool {
        !days.isEmpty
    }

    private var displayText: String {
        hasRecords ? selectedDay : "기록된 시험 없음"
    }

    // MARK: - Initializer

    public init(days: [String], selectedDay: Binding<String>, isExpanded: Binding<Bool>) {
        self.days = days
        _selectedDay = selectedDay
        _isExpanded = isExpanded
    }

    // MARK: - Body

    public var body: some View {
        Button {
            guard hasRecords else { return }
            withAnimation(.easeInOut(duration: 0.2)) {
                isExpanded.toggle()
            }
        } label: {
            HStack {
                Text(displayText)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(hasRecords ? Color.coolNeutral600 : Color.coolNeutral300)

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(hasRecords ? Color.coolNeutral500 : Color.coolNeutral300)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    .animation(.easeInOut(duration: 0.2), value: isExpanded)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 14)
        }
        .disabled(!hasRecords)
        .background(Color.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.coolNeutral200, lineWidth: 1)
        )
    }
}

// MARK: - Dropdown List

public struct DaySelectDropdownList: View {

    public let days: [String]
    @Binding public var selectedDay: String
    @Binding public var isExpanded: Bool
    public var onDaySelected: ((String) -> Void)?

    // MARK: - Initializer

    public init(days: [String], selectedDay: Binding<String>, isExpanded: Binding<Bool>, onDaySelected: ((String) -> Void)? = nil) {
        self.days = days
        _selectedDay = selectedDay
        _isExpanded = isExpanded
        self.onDaySelected = onDaySelected
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("회차 선택")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color.coolNeutral600)
                .padding(.horizontal, 8)
                .padding(.vertical, 16)

            Divider()

            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(days, id: \.self) { day in
                        dayRow(for: day)
                    }
                }
            }
            .frame(maxHeight: 200)
        }
        .background(Color.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.coolNeutral200, lineWidth: 1)
        )
        .shadow(
            color: Color.coolNeutral300.opacity(0.12),
            radius: 4,
            x: 0,
            y: 1
        )
    }

    private func dayRow(for day: String) -> some View {
        let isSelected = selectedDay == day

        return Button {
            selectedDay = day
            onDaySelected?(day)
            withAnimation(.easeInOut(duration: 0.2)) {
                isExpanded = false
            }
        } label: {
            Text(day)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color.coolNeutral800)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 8)
                .padding(.vertical, 14)
                .background(isSelected ? Color.customBlue200 : Color.clear)
        }
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedDay = "Day6 (주간 복습)"
        @State private var isExpanded = true

        var body: some View {
            VStack {
                DaySelectDropdownButton(
                    days: ["Day6", "Day5", "Day4", "Day3", "Day2", "Day1"],
                    selectedDay: $selectedDay,
                    isExpanded: $isExpanded
                )

                if isExpanded {
                    DaySelectDropdownList(
                        days: ["Day6", "Day5", "Day4", "Day3", "Day2", "Day1"],
                        selectedDay: $selectedDay,
                        isExpanded: $isExpanded
                    )
                }
            }
            .padding()
            .background(Color(uiColor: .systemGroupedBackground))
        }
    }

    return PreviewWrapper()
}
