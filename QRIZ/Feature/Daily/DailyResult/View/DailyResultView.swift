//
//  DailyResultView.swift
//  QRIZ
//
//  Created by 이창현 on 4/16/25.
//

import SwiftUI
import Combine

struct DailyResultView: View {
    
    @StateObject var resultScoresData: ResultScoresData
    @StateObject var resultGradeListData: ResultGradeListData
    @StateObject var resultDetailData: ResultDetailData
    @State var dailyLearnType: DailyLearnType
    
    let input: PassthroughSubject<DailyResultViewModel.Input, Never> = .init()
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 0) {
                DailyResultScoreView(resultScoresData: resultScoresData,
                                     resultDetailData: resultDetailData,
                                     dailyLearnType: $dailyLearnType,
                                     input: input)
                Spacer(minLength: 16)
                DailyResultGradesListView(resultGradeListData: resultGradeListData)
                DailyResultFooterView(resultScoresData: resultScoresData)
            }
            .background(.customBlue50)
        }
        .background(.white)
    }
}

#Preview {
    DailyResultView(resultScoresData: ResultScoresData(), resultGradeListData: ResultGradeListData(), resultDetailData: ResultDetailData(), dailyLearnType: .daily)
}
