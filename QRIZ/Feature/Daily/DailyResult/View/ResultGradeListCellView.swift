//
//  GradeListCellView.swift
//  QRIZ
//
//  Created by 이창현 on 4/17/25.
//

import SwiftUI

struct ResultGradeListCellView: View {

    @State var skill: String
    @State var question: String
    @State var correction: Bool
    @State var questionNum: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                correctionImage()
                Text("문제 \(questionNum)")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }
            
            Text("\(question)")
            .font(.system(size: 14, weight: .regular))
            .lineLimit(2)
            
            HStack {
                Text("\(skill)")
                    .foregroundStyle(.customBlue400)
                    .font(.system(size: 12, weight: .semibold))
                    .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                    .background(Color.customBlue100, in: RoundedRectangle(cornerRadius: 4))
                Spacer()
            }
        }
        .padding(EdgeInsets(top: 20, leading: 16, bottom: 20, trailing: 16))
        .background(.white)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.customBlue100, lineWidth: 1))
    }
    
    @ViewBuilder
    private func correctionImage() -> some View {
        if correction {
            Image(systemName: "checkmark")
                .resizable()
                .frame(width: 15, height: 12)
                .foregroundStyle(.customMint600)
        } else {
            Image(systemName: "xmark")
                .resizable()
                .frame(width: 10.5, height: 10.5)
                .foregroundStyle(.customRed500)
        }
    }
}

#Preview {
    ResultGradeListCellView(skill: "엔터티",
                            question: """
                                아래 테이블 T<S<R이 각각 다음과 같이 선언되었다. 
                                다음 중 DELETE FROM T;를 수행한 후에 테이블 R에 남아있는 데이터로 가장 적절한 것은?
                            """,
                            correction: false,
                            questionNum: 1)
}
