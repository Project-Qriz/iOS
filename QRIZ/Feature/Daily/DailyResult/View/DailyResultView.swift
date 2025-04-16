//
//  DailyResultView.swift
//  QRIZ
//
//  Created by 이창현 on 4/16/25.
//

import SwiftUI

struct DailyResultView: View {
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 0) {
                DailyResultScoreView()
                Spacer(minLength: 16)
                DailyResultGradeListView()
                DailyResultFooterView()
            }
            .background(.customBlue50)
        }
    }
}

#Preview {
    DailyResultView()
}
