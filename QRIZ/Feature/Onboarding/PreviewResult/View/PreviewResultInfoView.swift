//
//  PreviewResultInfoView.swift
//  QRIZ
//
//  Created by ch on 3/18/25.
//

import SwiftUI

struct PreviewResultInfoView: View {
    
    @Binding var isShowingPopover: Bool
    
    var body: some View {
        VStack {
            HStack {
                Text("예측 점수란?")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.coolNeutral800)
                
                Spacer(minLength: 13)
                
                Button(action: {
                    isShowingPopover.toggle()
                }, label: {
                    Image(systemName: "xmark")
                        .frame(width: 8, height: 8)
                        .foregroundStyle(.coolNeutral300)
                })
            }
            
            Spacer()

            VStack(alignment: .leading, spacing: 14) {
                Text("출제 경향을 반영한 가중치를 적용하여, 예상한 점수입니다.")

                Text("* 실제 시험에서는 난이도나 변동 요소에 따라 점수가 달라질 수 있습니다.")
            }
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.coolNeutral500)
        }
        .padding(EdgeInsets(top: 20, leading: 16, bottom: 20, trailing: 16))
        .overlay(RoundedRectangle(cornerRadius: 8)
            .stroke(
                Color.coolNeutral200,
                lineWidth: 2
            )
        )
        .frame(width: 250, height: 150)
        .background(.white)
    }
    
}

#Preview {
    PreviewResultInfoView(isShowingPopover: .constant(true))
}
