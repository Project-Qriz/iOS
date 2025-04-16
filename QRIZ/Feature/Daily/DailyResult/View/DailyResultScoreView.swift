//
//  DailyResultScoreView.swift
//  QRIZ
//
//  Created by 이창현 on 4/16/25.
//

import SwiftUI

struct DailyResultScoreView: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("채영님의\n").font(.system(size: 20, weight: .regular)) +
                Text("데일리 테스트 결과").font(.system(size: 20, weight: .bold))
                Text("에요!").font(.system(size: 20, weight: .regular))
                
                Spacer()
                
            }
            .foregroundStyle(.coolNeutral800)

            // graph
            // subject list
        }
        .padding(EdgeInsets(top: 24, leading: 18, bottom: 24, trailing: 18))
        .background(.white)
    }
}

#Preview {
    DailyResultScoreView()
}
