//
//  SingleSubjectView.swift
//  ExamKit
//

import SwiftUI
import DesignSystem

public struct SingleSubjectView: View {

    private let circleColor: Color
    private let subjectText: String
    private let score: Int

    public init(circleColor: Color, subjectText: String, score: CGFloat) {
        self.circleColor = circleColor
        self.subjectText = subjectText
        self.score = Int(score)
    }

    public var body: some View {
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
                .foregroundStyle(Color.coolNeutral800)
        }
    }
}

#Preview {
    SingleSubjectView(circleColor: Color.customBlue800, subjectText: "임시", score: 20)
}
