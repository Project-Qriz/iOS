//
//  TestResultGradesListView.swift
//  ExamKit
//

import SwiftUI
import DesignSystem
import Combine
import QRIZUtils

public struct TestResultGradesListView: View {

    @ObservedObject public var resultGradeListData: ResultGradeListData
    public let onProblemTap: PassthroughSubject<Int, Never>

    public init(resultGradeListData: ResultGradeListData, onProblemTap: PassthroughSubject<Int, Never>) {
        self.resultGradeListData = resultGradeListData
        self.onProblemTap = onProblemTap
    }

    public var body: some View {
        LazyVStack(spacing: 16) {
            HStack {
                Text("문제 풀이 결과")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.coolNeutral800)
                Spacer()
            }

            ForEach(resultGradeListData.gradeResultList) { gradeResult in
                ResultGradeListCellView(gradeResult: gradeResult) {
                    onProblemTap.send(gradeResult.questionId)
                }
            }
        }
        .padding(.top, 24)
        .padding(.horizontal, 18)
        .padding(.bottom, 16)
        .background(.white)
    }
}

#Preview {
    TestResultGradesListView(
        resultGradeListData: ResultGradeListData(),
        onProblemTap: PassthroughSubject<Int, Never>()
    )
}
