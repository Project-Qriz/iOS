import Foundation
import QRIZUtils
import Network

@MainActor
final class CheckConceptViewModel: ObservableObject {
    @Published var selectedSet: Set<Int> = []
    @Published var isDoneButtonEnabled: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    var onNavigateToPreviewTest: (() -> Void)?
    var onNavigateToGreeting: (() -> Void)?

    private let onboardingService: OnboardingService

    init(onboardingService: OnboardingService) {
        self.onboardingService = onboardingService
    }

    func didTapAll() {
        if selectedSet.count == SurveyCheckList.list.count {
            selectedSet.removeAll()
        } else {
            selectedSet = Set(0..<SurveyCheckList.list.count)
        }
        updateDoneButton()
    }

    func didTapNone() {
        selectedSet.removeAll()
        isDoneButtonEnabled = true
    }

    func didTapConcept(idx: Int) {
        if selectedSet.contains(idx) {
            selectedSet.remove(idx)
        } else {
            selectedSet.insert(idx)
        }
        updateDoneButton()
    }

    func didTapDone() {
        guard isDoneButtonEnabled, !isLoading else { return }
        Task { await sendSurvey() }
    }

    private func updateDoneButton() {
        isDoneButtonEnabled = !selectedSet.isEmpty
    }

    private func sendSurvey() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let keyConcepts = selectedSet.map { SurveyCheckList.list[$0] }
            _ = try await onboardingService.sendSurvey(keyConcepts: keyConcepts)
            UserInfoManager.shared.previewTestStatus = .surveyCompleted
            if selectedSet.isEmpty {
                onNavigateToGreeting?()
            } else {
                onNavigateToPreviewTest?()
            }
        } catch {
            errorMessage = "잠시 후 다시 시도해주세요."
        }
    }
}
