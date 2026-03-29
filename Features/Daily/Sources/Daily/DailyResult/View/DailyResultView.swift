//
//  DailyResultView.swift
//  QRIZ
//
//  Created by 이창현 on 4/16/25.
//

import SwiftUI
import Combine
import DesignSystem
import ExamKit

struct DailyResultView: View {

    // MARK: - Properties

    @ObservedObject var viewModel: DailyResultViewModel
    @StateObject private var bridge = DailyResultExamKitBridge()

    // MARK: - Body

    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 0) {
                DailyResultScoreView(
                    resultScoresData: viewModel.resultScoresData,
                    resultDetailData: viewModel.resultDetailData,
                    dailyLearnType: viewModel.dailyTestType,
                    onDetailTap: viewModel.didTapResultDetail
                )
                Spacer(minLength: 16)
                TestResultGradesListView(
                    resultGradeListData: viewModel.resultGradeListData,
                    onProblemTap: bridge.problemTap
                )
                TestResultFooterView(
                    resultScoresData: viewModel.resultScoresData,
                    input: bridge.conceptTap
                )
            }
            .background(Color.customBlue50)
        }
        .background(.white)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("시험 결과")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.coolNeutral700)
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: viewModel.didTapCancel) {
                    Image(systemName: "xmark")
                        .foregroundStyle(Color.coolNeutral800)
                }
            }
        }
        .alert("오류", isPresented: isErrorPresented) {
            Button("확인", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onReceive(bridge.conceptTap) { viewModel.didTapConcept() }
        .onReceive(bridge.problemTap) { viewModel.didTapProblem(questionId: $0) }
        .onAppear(perform: viewModel.onViewDidLoad)
    }
}

// MARK: - Private

private extension DailyResultView {
    var isErrorPresented: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )
    }
}

// MARK: - Bridge

private final class DailyResultExamKitBridge: ObservableObject {
    let conceptTap = PassthroughSubject<Void, Never>()
    let problemTap = PassthroughSubject<Int, Never>()
}
