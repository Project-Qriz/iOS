import Foundation
import Network

@MainActor
final class PlanDurationSelectionViewModel: ObservableObject {

    // MARK: - Properties

    @Published var selectedPlanType: Int? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let dailyService: any DailyService
    private let onNavigate: () -> Void

    // MARK: - Initialization

    init(
        dailyService: any DailyService,
        onNavigate: @escaping () -> Void
    ) {
        self.dailyService = dailyService
        self.onNavigate = onNavigate
    }

    // MARK: - Methods

    func didSelectPlan(_ planType: Int) {
        selectedPlanType = planType
    }

    func didTapConfirm() {
        guard let planType = selectedPlanType, !isLoading else { return }
        isLoading = true
        Task { await selectPlan(planType: planType) }
    }

    // MARK: - Private

    private func selectPlan(planType: Int) async {
        defer { isLoading = false }
        do {
            _ = try await dailyService.selectPlan(planType: planType)
            onNavigate()
        } catch {
            errorMessage = "잠시 후 다시 시도해주세요."
        }
    }
}
