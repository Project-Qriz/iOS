//
//  ResultGradeListCellView.swift
//  ExamKit
//

import SwiftUI
import DesignSystem
import QRIZUtils

public struct ResultGradeListCellView: View {

    // MARK: - Properties
    private let gradeResult: GradeResult
    private let onTap: () -> Void

    // MARK: - Initializers
    public init(gradeResult: GradeResult, onTap: @escaping () -> Void) {
        self.gradeResult = gradeResult
        self.onTap = onTap
    }

    // MARK: - Body
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                gradeIcon()
                Text("문제 \(gradeResult.id)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.coolNeutral800)
                Spacer()
            }

            Text(gradeResult.question)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color.coolNeutral600)
                .lineLimit(2)

            HStack {
                Text(gradeResult.skillName)
                    .foregroundStyle(Color.customBlue400)
                    .font(.system(size: 12, weight: .semibold))
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(Color.customBlue100, in: RoundedRectangle(cornerRadius: 4))
                Spacer()
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(.white)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.customBlue100, lineWidth: 1))
        .onTapGesture(perform: onTap)
    }

    // MARK: - Methods
    @ViewBuilder
    private func gradeIcon() -> some View {
        if gradeResult.correction {
            Image(systemName: "checkmark")
                .resizable()
                .frame(width: 15, height: 12)
                .foregroundStyle(Color.customMint600)
        } else {
            Image(systemName: "xmark")
                .resizable()
                .frame(width: 10.5, height: 10.5)
                .foregroundStyle(Color.customRed500)
        }
    }
}

#Preview {
    ResultGradeListCellView(
        gradeResult: GradeResult(
            id: 1,
            questionId: 168,
            skillName: "엔터티",
            question: """
                아래 테이블 T<S<R이 각각 다음과 같이 선언되었다.
                다음 중 DELETE FROM T;를 수행한 후에 테이블 R에 남아있는 데이터로 가장 적절한 것은?
            """,
            correction: false),
        onTap: {}
    )
}
