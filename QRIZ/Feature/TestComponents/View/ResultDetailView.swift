//
//  ResultDetailView.swift
//  QRIZ
//
//  Created by ch on 4/19/25.
//

import SwiftUI
import Combine

struct ResultDetailView: View {
    
    @StateObject var resultScoreData: ResultScoresData
    @StateObject var resultDetailData: ResultDetailData
    let input: PassthroughSubject<ResultDetailViewModel.Input, Never> = .init()
    
    var body: some View {
        ScrollView() {
            LazyVStack {
                HStack {
                    Text("개념별 점수 분석")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.coolNeutral800)
                    Spacer()
                }
                
                Spacer(minLength: 8)
                
                HStack(spacing: 0) {
                    Picker("과목", selection: $resultScoreData.selectedMenuItem) {
                        ForEach(ResultDetailMenuItems.allCases, id: \.self) { item in
                            Text(item.rawValue)
                        }
                    }
                    .menuIndicator(.hidden)
                    .tint(.coolNeutral600)
                    .onChange(of: resultScoreData.selectedMenuItem) { selectedItem in
                        input.send(.menuItemSelected(selected: selectedItem))
                    }
                    
                    Image(systemName: "chevron.down")
                        .foregroundStyle(.coolNeutral600)
                        .frame(width: 9, height: 4)
                    
                    Spacer()
                }
                
                Spacer(minLength: 24)
                
                ResultScoreCircularChartView(resultScoresData: resultScoreData)
                    .frame(width: 164, height: 164)
                
                Spacer(minLength: 32)
                
                ResultDetailScoreView(resultScoreData: resultScoreData, resultDetailData: resultDetailData)
            }
            .padding(EdgeInsets(top: 24, leading: 18, bottom: 24, trailing: 18))
            .background(.white)
        }
        .background(.white)
    }
}

#Preview {
    ResultDetailView(resultScoreData: ResultScoresData(), resultDetailData: ResultDetailData())
}
