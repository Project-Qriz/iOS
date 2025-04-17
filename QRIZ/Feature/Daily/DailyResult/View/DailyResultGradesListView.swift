//
//  DailyResultGradeListView.swift
//  QRIZ
//
//  Created by 이창현 on 4/16/25.
//

import SwiftUI

struct DailyResultGradesListView: View {
    var body: some View {
        LazyVStack(spacing: 16) {
            HStack {
                Text("문제 풀이 결과")
                    .font(.system(size: 20, weight: .bold))
                Spacer()
            }
            
            ForEach(1..<6) { _ in
                ResultGradeListCellView()
            }
        }
        .padding(EdgeInsets(top: 24, leading: 18, bottom: 16, trailing: 18))
        .background(.white)
    }
}

#Preview {
    DailyResultGradesListView()
}
