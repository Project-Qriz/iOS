//
//  MistakeNoteMainView.swift
//  QRIZ
//
//  Created by Claude on 1/13/26.
//

import SwiftUI

struct MistakeNoteMainView: View {

    // MARK: - Properties

    @State private var selectedTab: MistakeNoteTab = .daily
    @State private var selectedDay: String = "Day6 (주간 복습)"
    @State private var isDayDropdownExpanded: Bool = false

    // Filter states
    @State private var filterAll: String = "모두"
    @State private var filterSubject1: String = "1과목"
    @State private var filterSubject2: String = "2과목"
    @State private var expandedFilter: FilterType? = nil

    // TODO: API에서 받아올 데이터
    private let availableDays: [String] = [
        "Day6 (주간 복습)",
        "Day5",
        "Day4",
        "Day3",
        "Day2",
        "Day1"
    ]

    // MARK: - Body

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

            filterChipsRow
                .padding(.horizontal, 18)
                .padding(.top, 16)

            Spacer()
        }
        .background(Color.white)
    }
}

// MARK: - Subviews

private extension MistakeNoteMainView {

    var filterChipsRow: some View {
        HStack(spacing: 8) {
            FilterChipButton(
                title: "모두",
                options: ["모두", "오답만"],
                selectedOption: $filterAll,
                isExpanded: Binding(
                    get: { expandedFilter == .all },
                    set: { expandedFilter = $0 ? .all : nil }
                )
            )

            Divider()
                .frame(height: 32)
                .background(Color(uiColor: .coolNeutral200))

            FilterChipButton(
                title: "1과목",
                options: ["1과목", "오답만"],
                selectedOption: $filterSubject1,
                isExpanded: Binding(
                    get: { expandedFilter == .subject1 },
                    set: { expandedFilter = $0 ? .subject1 : nil }
                )
            )

            FilterChipButton(
                title: "2과목",
                options: ["2과목", "오답만"],
                selectedOption: $filterSubject2,
                isExpanded: Binding(
                    get: { expandedFilter == .subject2 },
                    set: { expandedFilter = $0 ? .subject2 : nil }
                )
            )

            Spacer()
        }
    }
}

// MARK: - FilterType

private enum FilterType {
    case all
    case subject1
    case subject2
}

// MARK: - Preview

#Preview {
    MistakeNoteMainView()
}
