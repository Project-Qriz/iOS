//
//  MistakeNoteTabSelector.swift
//  QRIZ
//
//  Created by Claude on 1/13/26.
//

import SwiftUI

enum MistakeNoteTab: String, CaseIterable {
    case daily = "데일리"
    case mockExam = "모의고사"
}

struct MistakeNoteTabSelector: View {

    @Binding var selectedTab: MistakeNoteTab

    var body: some View {
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
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 10) {
                Text(tab.rawValue)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(uiColor: isSelected ? .coolNeutral800 : .coolNeutral400))

                Rectangle()
                    .fill(isSelected ? Color(uiColor: .coolNeutral800) : Color.clear)
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
                MistakeNoteTabSelector(selectedTab: $selectedTab)
                    .padding(.horizontal, 18)

                Spacer()
            }
            .background(Color.white)
        }
    }

    return PreviewWrapper()
}
