//
//  DailyResultView.swift
//  QRIZ
//
//  Created by 이창현 on 4/16/25.
//

import SwiftUI
import Combine

struct DailyResultView: View {
    
    @StateObject var resultScorsData: ResultScoresData
    @StateObject var resultGradeListData: ResultGradeListData
    @StateObject var resultDetailData: ResultDetailData
    @State var dailyLearnType: DailyLearnType
    
    let input: PassthroughSubject<DailyResultViewModel.Input, Never> = .init()
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 0) {
                DailyResultScoreView(resultScoresData: resultScorsData,
                                     resultDetailData: resultDetailData,
                                     dailyLearnType: $dailyLearnType,
                                     input: input)
                Spacer(minLength: 16)
                DailyResultGradesListView(resultGradeListData: resultGradeListData)
                DailyResultFooterView()
            }
            .background(.customBlue50)
        }
        .background(.white)
    }
}

#Preview {
    DailyResultView(resultScorsData: ResultScoresData(), resultGradeListData: ResultGradeListData(), resultDetailData: ResultDetailData(), dailyLearnType: .daily)
}
