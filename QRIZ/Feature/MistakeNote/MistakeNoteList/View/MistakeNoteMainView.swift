//
//  MistakeNoteMainView.swift
//  QRIZ
//
//  Created by Claude on 1/13/26.
//

import SwiftUI

struct MistakeNoteMainView: View {

    @State private var selectedTab: MistakeNoteTab = .daily
    @State private var selectedDay: String = "Day6 (주간 복습)"
    @State private var isDayDropdownExpanded: Bool = false

    // TODO: API에서 받아올 데이터
    private let availableDays: [String] = [
        "Day6 (주간 복습)",
        "Day5",
        "Day4",
        "Day3",
        "Day2",
        "Day1"
    ]

    var body: some View {
        VStack(spacing: 0) {
            MistakeNoteTabSelector(selectedTab: $selectedTab)
                .padding(.horizontal, 18)
                .padding(.top, 16)

            DaySelectDropdownButton(
                days: availableDays,
                selectedDay: $selectedDay,
                isExpanded: $isDayDropdownExpanded
            )
            .padding(.horizontal, 18)
            .padding(.top, 20)

            Spacer()
        }
        .background(Color.white)
    }
}

// MARK: - Preview

#Preview {
    MistakeNoteMainView()
}
