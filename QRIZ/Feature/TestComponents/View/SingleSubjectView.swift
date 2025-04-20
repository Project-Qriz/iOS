//
//  SingleSubjectView.swift
//  QRIZ
//
//  Created by 이창현 on 4/17/25.
//

import SwiftUI

struct SingleSubjectView: View {

    private let circleColor: Color
    private let subjectText: String
    private let score: Int
    
    init(circleColor: Color, subjectText: String, score: CGFloat) {
        self.circleColor = circleColor
        self.subjectText = subjectText
        self.score = Int(score)
    }
    
    var body: some View {
        HStack {
            Circle()
                .frame(width: 8, height: 8)
                .foregroundColor(circleColor)
            Text(subjectText)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(.black)
            Spacer()
            Text("\(score)점")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.coolNeutral800)
        }
    }
}

#Preview {
    SingleSubjectView(circleColor: .customBlue800, subjectText: "임시", score: 20)
}
