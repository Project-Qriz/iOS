//
//  DailyResultFooterView.swift
//  QRIZ
//
//  Created by 이창현 on 4/16/25.
//

import SwiftUI
import Combine

struct DailyResultFooterView: View {
    
    @ObservedObject var resultScoresData: ResultScoresData
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("\(resultScoresData.nickname)님이 ") +
                Text("보완하면 좋은 개념을\n").font(.system(size: 18, weight: .bold)) +
                Text("보러갈까요?")
                
                Spacer()
            }
            .font(.system(size: 18, weight: .regular))
            .foregroundStyle(.coolNeutral800)

            Button {
                
            } label: {
                Text("개념서 보러 가기")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(height: 48)
                    .frame(maxWidth: .infinity)
                    .background(.customBlue500)
                    .cornerRadius(8, corners: .allCorners)
            }
        }
        .padding(EdgeInsets(top: 16, leading: 18, bottom: 24, trailing: 18))
        .background(.white)
    }
}

#Preview {
    DailyResultFooterView(resultScoresData: ResultScoresData())
}
