//
//  ExamResultView.swift
//  QRIZ
//
//  Created by 이창현 on 5/26/25.
//

import SwiftUI
import Combine

struct ExamResultView: View {

    @ObservedObject var resultScoresData: ResultScoresData
    @ObservedObject var resultGradeListData: ResultGradeListData
    @ObservedObject var resultDetailData: ResultDetailData
    @ObservedObject var scoreGraphData: ScoreGraphData

    private let contentsInput: PassthroughSubject<Void, Never> = .init()
    private let footerInput: PassthroughSubject<Void, Never> = .init()
    private let problemTapInput: PassthroughSubject<Int, Never> = .init()

    var resultDetailTappedPublisher: AnyPublisher<Void, Never> {
        contentsInput.eraseToAnyPublisher()
    }
    var conceptTappedPublisher: AnyPublisher<Void, Never> {
        footerInput.eraseToAnyPublisher()
    }
    var problemTappedPublisher: AnyPublisher<Int, Never> {
        problemTapInput.eraseToAnyPublisher()
    }
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 0) {
                ExamResultScoreView(resultScoresData: resultScoresData,
                                     resultDetailData: resultDetailData,
                                     input: contentsInput)
                Spacer(minLength: 16)
                
                if scoreGraphData.totalScores.count > 1 {
                    ExamScoresGraphView(scoreGraphData: scoreGraphData)
                    
                    Spacer(minLength: 16)
                }

                TestResultGradesListView(
                    resultGradeListData: resultGradeListData,
                    onProblemTap: problemTapInput
                )

                TestResultFooterView(resultScoresData: resultScoresData, input: footerInput)
            }
            .background(.customBlue50)
        }
        .background(.white)
    }
}

#Preview {
    ExamResultView(resultScoresData: ResultScoresData(), resultGradeListData: ResultGradeListData(), resultDetailData: ResultDetailData(),
        scoreGraphData: ScoreGraphData())
}
