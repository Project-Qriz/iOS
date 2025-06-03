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
    @StateObject var scoreGraphData: ScoreGraphData
    
    private let contentsInput: PassthroughSubject<Void, Never> = .init()
    private let footerInput: PassthroughSubject<Void, Never> = .init()
    
    var resultDetailTappedPublisher: AnyPublisher<Void, Never> {
        contentsInput.eraseToAnyPublisher()
    }
    var conceptTappedPublisher: AnyPublisher<Void, Never> {
        footerInput.eraseToAnyPublisher()
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

                TestResultGradesListView(resultGradeListData: resultGradeListData)
                
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
