//
//  MistakeNoteTabSelector.swift
//  MistakeNote
//
//  Created by Claude on 1/13/26.
//

import SwiftUI
import DesignSystem

public enum MistakeNoteTab: String, CaseIterable, Sendable {
    case daily = "데일리"
    case mockExam = "모의고사"
}

public struct MistakeNoteTabSelector: View {

    public let selectedTab: MistakeNoteTab
    public let onTabSelected: (MistakeNoteTab) -> Void

    // MARK: - Initializer

    public init(
        selectedTab: MistakeNoteTab,
        onTabSelected: @escaping (MistakeNoteTab) -> Void
    ) {
        self.selectedTab = selectedTab
        self.onTabSelected = onTabSelected
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(MistakeNoteTab.allCases, id: \.self) { tab in
                tabItem(for: tab)
            }
        }
    }
}

// MARK: - Subviews

private extension MistakeNoteTabSelector {

    func tabItem(for tab: MistakeNoteTab) -> some View {
        let isSelected = selectedTab == tab

        return Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                onTabSelected(tab)
            }
        } label: {
            VStack(spacing: 10) {
                Text(tab.rawValue)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isSelected ? Color.coolNeutral800 : Color.coolNeutral400)

                Rectangle()
                    .fill(isSelected ? Color.coolNeutral800 : Color.clear)
                    .frame(height: 3)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedTab: MistakeNoteTab = .daily

        var body: some View {
            VStack {
                MistakeNoteTabSelector(
                    selectedTab: selectedTab,
                    onTabSelected: { selectedTab = $0 }
                )
                .padding(.horizontal, 18)

                Spacer()
            }
            .background(Color.white)
        }
    }

    return PreviewWrapper()
}
