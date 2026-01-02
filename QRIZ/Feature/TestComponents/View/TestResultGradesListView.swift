//
//  DailyResultGradeListView.swift
//  QRIZ
//
//  Created by 이창현 on 4/16/25.
//

import SwiftUI
import Combine

struct TestResultGradesListView: View {
    
    @ObservedObject var resultGradeListData: ResultGradeListData
    let onProblemTap: PassthroughSubject<Int, Never>
    
    var body: some View {
        LazyVStack(spacing: 16) {
            HStack {
                Text("문제 풀이 결과")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.coolNeutral800)
                Spacer()
            }
            
            ForEach(resultGradeListData.gradeResultList) { gradeResult in
                ResultGradeListCellView(gradeResult: gradeResult) {
                    onProblemTap.send(gradeResult.id)
                }
            }
        }
        .padding(EdgeInsets(top: 24, leading: 18, bottom: 16, trailing: 18))
        .background(.white)
    }
}

#Preview {
    TestResultGradesListView(
        resultGradeListData: ResultGradeListData(),
        onProblemTap: PassthroughSubject<Int, Never>()
    )
}
