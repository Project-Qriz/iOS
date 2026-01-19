//
//  SubjectFilterSheet.swift
//  QRIZ
//
//  Created by Claude on 1/19/26.
//

import SwiftUI

struct SubjectFilterSheet: View {

    // MARK: - Properties

    @Binding var isPresented: Bool
    @State private var selectedSubject: SubjectTab = .subject2

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            SubjectTabSelector(selectedTab: $selectedSubject)
                .padding(.top, 24)

            Spacer()
        }
        .background(Color.white)
    }
}

// MARK: - Subject Tab

enum SubjectTab: String, CaseIterable {
    case subject1 = "1과목"
    case subject2 = "2과목"
}

// MARK: - Tab Selector

struct SubjectTabSelector: View {
    @Binding var selectedTab: SubjectTab

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(SubjectTab.allCases, id: \.self) { tab in
                    tabButton(for: tab)
                }
                Spacer()
            }
            .padding(.horizontal, 18)

            Rectangle()
                .fill(Color(uiColor: .coolNeutral100))
                .frame(height: 1)
                .padding(.horizontal, 18)
        }
    }

    private func tabButton(for tab: SubjectTab) -> some View {
        let isSelected = selectedTab == tab

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 10) {
                Text(tab.rawValue)
                    .font(.system(size: 16, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? Color(uiColor: .coolNeutral800) : Color(uiColor: .coolNeutral400))

                Rectangle()
                    .fill(isSelected ? Color(uiColor: .coolNeutral800) : Color.clear)
                    .frame(height: 3)
            }
            .frame(width: 60)
        }
    }
}

// MARK: - Preview

#Preview {
    SubjectFilterSheet(isPresented: .constant(true))
}
