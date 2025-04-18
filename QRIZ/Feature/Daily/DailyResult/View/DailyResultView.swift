//
//  DailyResultView.swift
//  QRIZ
//
//  Created by 이창현 on 4/16/25.
//

import SwiftUI

struct DailyResultView: View {
    
    @StateObject var resultScorsData: ResultScoresData
    @StateObject var resultGradeListData: ResultGradeListData
    @State var dailyLearnType: DailyLearnType
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 0) {
                DailyResultScoreView(resultScoresData: resultScorsData, dailyLearnType: $dailyLearnType)
                Spacer(minLength: 16)
                DailyResultGradesListView(resultGradeListData: resultGradeListData)
                DailyResultFooterView()
            }
            .background(.customBlue50)
        }
    }
}

#Preview {
    DailyResultView(resultScorsData: ResultScoresData(), resultGradeListData: ResultGradeListData(), dailyLearnType: .daily)
}
