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
    @State private var expandedFilter: FilterType? = nil
    @State private var showSubjectFilterSheet: Bool = false
    
    // TODO: API에서 받아올 데이터
    private let availableDays: [String] = [
        "Day6 (주간 복습)",
        "Day5",
        "Day4",
        "Day3",
        "Day2",
        "Day1"
    ]

    private let sampleQuestions: [MistakeNoteQuestion] = [
        MistakeNoteQuestion(
            id: 232371,
            questionNum: 1,
            question: "다음 SQL문에서 발생할 수 있는 문제점으로 가장 적절한 것은?",
            correction: false,
            keyConcepts: "WHERE 절",
            date: "2026-01-10T20:21:16.217871"
        ),
        MistakeNoteQuestion(
            id: 232372,
            questionNum: 2,
            question: "다음 중 가장 적절한 속성 설계는?",
            correction: true,
            keyConcepts: "속성",
            date: "2026-01-10T20:21:16.231237"
        ),
        MistakeNoteQuestion(
            id: 232373,
            questionNum: 3,
            question: "다음과 같은 WHERE 절에서 인덱스를 효율적으로 사용할 수 있는 조건은?",
            correction: false,
            keyConcepts: "WHERE 절",
            date: "2026-01-10T20:21:16.234266"
        )
    ]
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    MistakeNoteTabSelector(selectedTab: $selectedTab)
                        .padding(.horizontal, 18)
                        .padding(.top, 16)
                }
                .background(Color.white)

                ScrollView {
                    VStack(spacing: 0) {
                        DaySelectDropdownButton(
                            days: availableDays,
                            selectedDay: $selectedDay,
                            isExpanded: $isDayDropdownExpanded
                        )
                        .padding(.horizontal, 18)
                        .padding(.top, 24)

                        filterChipsRow
                            .padding(.horizontal, 18)
                            .padding(.top, 16)

                        MistakeNoteQuestionListView(questions: sampleQuestions)
                            .padding(.horizontal, 18)
                            .padding(.top, 16)
                            .padding(.bottom, 24)
                    }
                }
            }
            
            if isDayDropdownExpanded {
                Color.black.opacity(0.01)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isDayDropdownExpanded = false
                        }
                    }

                DaySelectDropdownList(
                    days: availableDays,
                    selectedDay: $selectedDay,
                    isExpanded: $isDayDropdownExpanded
                )
                .padding(.horizontal, 18)
                .padding(.top, 120)
            }
        }
        .background(Color(uiColor: .customBlue50))
        .animation(.easeInOut(duration: 0.1), value: isDayDropdownExpanded)
        .sheet(isPresented: $showSubjectFilterSheet) {
            SubjectFilterSheet(isPresented: $showSubjectFilterSheet)
                .presentationDetents([.fraction(0.6)])
                .presentationDragIndicator(.visible)
        }
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

            subjectFilterButton(title: "1과목")
            subjectFilterButton(title: "2과목")

            Spacer()
        }
    }

    func subjectFilterButton(title: String) -> some View {
        Button {
            showSubjectFilterSheet = true
        } label: {
            HStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))

                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .semibold))
            }
            .foregroundColor(Color(uiColor: .coolNeutral500))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(uiColor: .coolNeutral200), lineWidth: 1)
            )
        }
    }
}

// MARK: - FilterType

private enum FilterType {
    case all
}

// MARK: - Preview

#Preview {
    MistakeNoteMainView()
}
