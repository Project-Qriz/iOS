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

            Text("총점수를 토대로,\n실제 시험 점수를 예측한 값입니다.")
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
        .frame(width: 200, height: 100)
        .background(.white)
    }
    
}

#Preview {
    PreviewResultInfoView(isShowingPopover: .constant(true))
}
