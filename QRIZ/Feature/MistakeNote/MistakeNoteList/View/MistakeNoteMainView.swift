//
//  MistakeNoteMainView.swift
//  QRIZ
//
//  Created by Claude on 1/13/26.
//

import SwiftUI

struct MistakeNoteMainView: View {

    @State private var selectedTab: MistakeNoteTab = .daily

    var body: some View {
        VStack(spacing: 0) {
            MistakeNoteTabSelector(selectedTab: $selectedTab)
                .padding(.horizontal, 18)
                .padding(.top, 16)

            Spacer()
        }
        .background(Color.white)
    }
}

// MARK: - Preview

#Preview {
    MistakeNoteMainView()
}
