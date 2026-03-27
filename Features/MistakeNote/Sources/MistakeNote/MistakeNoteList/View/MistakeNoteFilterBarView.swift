//
//  MistakeNoteFilterBarView.swift
//  MistakeNote
//

import SwiftUI
import DesignSystem
import QRIZUtils

struct MistakeNoteFilterBarView: View {

    // MARK: - Properties

    let filterAll: QuestionFilter
    let hasActiveConceptFilter: Bool
    let hasFilterForSubject: (Subject) -> Bool
    let onFilterAllChanged: (QuestionFilter) -> Void
    let onSubjectTapped: (Subject) -> Void
    let onReset: () -> Void

    @State private var expandedFilter: FilterType? = nil

    // MARK: - Body

    var body: some View {
        HStack(spacing: 8) {
            FilterChipButton(
                title: "모두",
                options: QuestionFilter.allCases.map { $0.rawValue },
                selectedOption: Binding(
                    get: { filterAll.rawValue },
                    set: { raw in
                        if let filter = QuestionFilter(rawValue: raw) {
                            onFilterAllChanged(filter)
                        }
                    }
                ),
                isExpanded: Binding(
                    get: { expandedFilter == .all },
                    set: { expandedFilter = $0 ? .all : nil }
                )
            )

            Divider()
                .frame(height: 32)
                .background(Color.coolNeutral200)

            if hasActiveConceptFilter {
                resetButton
            }

            subjectButton(subject: .one, title: "1과목")
            subjectButton(subject: .two, title: "2과목")

            Spacer()
        }
    }

    // MARK: - Subviews

    private var resetButton: some View {
        Button {
            onReset()
        } label: {
            HStack(spacing: 4) {
                Text("초기화")
                    .font(.system(size: 14, weight: .medium))

                Image(systemName: "arrow.trianglehead.2.counterclockwise.rotate.90")
                    .font(.system(size: 12, weight: .regular))
            }
            .foregroundColor(Color.coolNeutral500)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.coolNeutral200, lineWidth: 1)
            )
        }
    }

    private func subjectButton(subject: Subject, title: String) -> some View {
        let isActive = hasFilterForSubject(subject)

        return Button {
            onSubjectTapped(subject)
        } label: {
            HStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))

                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .semibold))
            }
            .foregroundColor(isActive ? .white : Color.coolNeutral500)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isActive ? Color.coolNeutral700 : Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isActive ? Color.clear : Color.coolNeutral200, lineWidth: 1)
            )
        }
    }
}

// MARK: - FilterType

private enum FilterType {
    case all
}
