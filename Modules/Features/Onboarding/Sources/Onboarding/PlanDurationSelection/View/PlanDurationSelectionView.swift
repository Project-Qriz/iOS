import SwiftUI
import QRIZNetwork
import DesignSystem
import QRIZUtils

struct PlanDurationSelectionView: View {

    // MARK: - Properties

    @ObservedObject var viewModel: PlanDurationSelectionViewModel

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            titleSection
            Spacer().frame(height: 32)
            planOptionList
            Spacer()
            confirmButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.coolNeutral100)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Content

private extension PlanDurationSelectionView {

    var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("며칠 동안 공부할까요?")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color.coolNeutral800)

            Text("기간에 맞게 개념과 문제를 배분해 드려요.")
                .font(.system(size: 16))
                .foregroundColor(Color.coolNeutral500)
        }
        .padding(.top, 48)
        .padding(.horizontal, 18)
    }

    var planOptionList: some View {
        VStack(spacing: 16) {
            ForEach(PlanOption.allCases) { option in
                PlanOptionCard(
                    option: option,
                    isSelected: viewModel.selectedPlanType == option.planType,
                    onTap: { viewModel.didSelectPlan(option.planType) }
                )
            }
        }
        .padding(.horizontal, 18)
    }

    var confirmButton: some View {
        Button {
            viewModel.didTapConfirm()
        } label: {
            Text("선택한 플랜으로 시작하기")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(viewModel.selectedPlanType != nil ? .white : .coolNeutral500)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(viewModel.selectedPlanType != nil ? Color.customBlue500 : Color.coolNeutral200)
                .cornerRadius(8)
        }
        .disabled(viewModel.selectedPlanType == nil || viewModel.isLoading)
        .padding(.horizontal, 18)
        .padding(.bottom, 16)
    }
}

// MARK: - Preview

private struct PreviewDailyService: DailyService {
    func getDailyDetailAndStatus(dayNumber: Int) async throws -> DailyDetailAndStatusResponse { fatalError() }
    func getDailyTestList(dayNumber: Int) async throws -> DailyTestListResponse { fatalError() }
    func submitDaily(dayNumber: Int, dailySubmitData: [DailySubmitData]) async throws { fatalError() }
    func getDailyTestResult(dayNumber: Int) async throws -> DailyResultResponse { fatalError() }
    func getDailyWeeklyScore(dayNumber: Int) async throws -> DailyWeeklyScoreResponse { fatalError() }
    func getDailyPlan() async throws -> DailyPlanResponse { fatalError() }
    func resetPlan() async throws -> DailyResetResponse { fatalError() }
    func selectPlan(planType: Int) async throws -> DailyPlanSelectResponse { fatalError() }
    func getDailyResultDetail(dayNumber: Int, questionId: Int) async throws -> DailyResultDetailResponse { fatalError() }
}

#Preview {
    PlanDurationSelectionView(
        viewModel: PlanDurationSelectionViewModel(
            dailyService: PreviewDailyService(),
            onNavigate: {}
        )
    )
}
