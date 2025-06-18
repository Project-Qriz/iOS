//
//  DailyResultView.swift
//  QRIZ
//
//  Created by 이창현 on 4/16/25.
//

import SwiftUI
import Combine

struct DailyResultView: View {
    
    @ObservedObject var resultScoresData: ResultScoresData
    @ObservedObject var resultGradeListData: ResultGradeListData
    @ObservedObject var resultDetailData: ResultDetailData
    @State var dailyLearnType: DailyLearnType
    
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
                DailyResultScoreView(resultScoresData: resultScoresData,
                                     resultDetailData: resultDetailData,
                                     dailyLearnType: $dailyLearnType,
                                     input: contentsInput)
                Spacer(minLength: 16)
                TestResultGradesListView(resultGradeListData: resultGradeListData)
                TestResultFooterView(resultScoresData: resultScoresData, input: footerInput)
            }
            .background(.customBlue50)
        }
        .background(.white)
    }
}

#Preview {
    DailyResultView(resultScoresData: ResultScoresData(), resultGradeListData: ResultGradeListData(), resultDetailData: ResultDetailData(), dailyLearnType: .daily)
}
