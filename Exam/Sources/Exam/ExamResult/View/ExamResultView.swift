import SwiftUI
import DesignSystem
import Combine
import QRIZUtils
import ExamKit

struct ExamResultView: View {

    // MARK: - Properties

    @ObservedObject var viewModel: ExamResultViewModel
    @StateObject private var bridge = ExamResultBridge()

    // MARK: - Body

    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 0) {
                ExamResultScoreView(
                    resultScoresData: viewModel.resultScoresData,
                    resultDetailData: viewModel.resultDetailData,
                    input: bridge.resultDetailTap
                )
                Spacer(minLength: 16)

                if viewModel.scoreGraphData.totalScores.count > 1 {
                    ExamScoresGraphView(scoreGraphData: viewModel.scoreGraphData)
                    Spacer(minLength: 16)
                }

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
        .onReceive(bridge.conceptTap) { viewModel.didTapMoveToConcept() }
        .onReceive(bridge.problemTap) { viewModel.didTapProblem(questionId: $0) }
        .onReceive(bridge.resultDetailTap) { viewModel.didTapResultDetail() }
        .onAppear(perform: viewModel.onViewDidLoad)
    }
}

// MARK: - Private

private extension ExamResultView {
    var isErrorPresented: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )
    }
}

// MARK: - Bridge

private final class ExamResultBridge: ObservableObject {
    let resultDetailTap = PassthroughSubject<Void, Never>()
    let conceptTap = PassthroughSubject<Void, Never>()
    let problemTap = PassthroughSubject<Int, Never>()
}
