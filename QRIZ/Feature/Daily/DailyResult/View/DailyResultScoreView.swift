//
//  DailyResultScoreView.swift
//  QRIZ
//
//  Created by 이창현 on 4/16/25.
//

import SwiftUI

struct DailyResultScoreView: View {
    var body: some View {
        VStack {
            HStack {
                Text("채영님의\n").font(.system(size: 20, weight: .regular)) +
                Text("데일리 테스트 결과에요!").font(.system(size: 20, weight: .bold))
                
                Spacer()
                
                // graph
                // subject list
            }
            .foregroundStyle(.coolNeutral800)
        }
        .padding(EdgeInsets(top: 24, leading: 18, bottom: 24, trailing: 18))
        .background(.white)
    }
}

#Preview {
    DailyResultScoreView()
}
