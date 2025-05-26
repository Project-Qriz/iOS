//
//  ExamResultView.swift
//  QRIZ
//
//  Created by 이창현 on 5/26/25.
//

import SwiftUI
import Combine

struct ExamResultView: View {
    
    @StateObject var resultScoresData: ResultScoresData
    @StateObject var resultGradeListData: ResultGradeListData
    @StateObject var resultDetailData: ResultDetailData
    
    let input: PassthroughSubject<ExamResultViewModel.Input, Never> = .init()
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 0) {
                ExamResultScoreView(resultScoresData: resultScoresData,
                                     resultDetailData: resultDetailData,
                                     input: input)
                Spacer(minLength: 16)
                TestResultGradesListView(resultGradeListData: resultGradeListData)
                TestResultFooterView(resultScoresData: resultScoresData)
            }
            .background(.customBlue50)
        }
        .background(.white)
    }
}

#Preview {
    ExamResultView(resultScoresData: ResultScoresData(), resultGradeListData: ResultGradeListData(), resultDetailData: ResultDetailData())
}
