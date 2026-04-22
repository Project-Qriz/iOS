import Foundation
import QRIZUtils
import Network

enum CheckConceptNavigation {
    case previewTest
    case greeting
}

@MainActor
final class CheckConceptViewModel: ObservableObject {

    // MARK: - Properties

    @Published var selectedSet: Set<Int> = []
    @Published var isDoneButtonEnabled: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    let sections: [(title: String, range: Range<Int>)] = [
        ("데이터 모델링의 이해", 0..<5),
        ("데이터 모델과 SQL", 5..<10),
        ("SQL 기본", 10..<18),
        ("SQL 활용", 18..<26),
        ("SQL 명령어", 26..<30),
    ]

    var isAllSelected: Bool {
        selectedSet.count == totalConceptCount
    }

    var allConceptIndices: Range<Int> {
        0..<totalConceptCount
    }

    private let onNavigate: (CheckConceptNavigation) -> Void
    private let onboardingService: OnboardingService
    private let userInfo: UserInfoManager

    // MARK: - Initializer

    init(
        onboardingService: OnboardingService,
        onNavigate: @escaping (CheckConceptNavigation) -> Void,
        userInfo: UserInfoManager = .shared
    ) {
        self.onboardingService = onboardingService
        self.onNavigate = onNavigate
        self.userInfo = userInfo
    }

    // MARK: - Methods

    func title(for index: Int) -> String {
        SurveyCheckList.list[index]
    }

    func didTapAll() {
        if selectedSet.count == totalConceptCount {
            selectedSet.removeAll()
        } else {
            selectedSet = Set(0..<totalConceptCount)
        }
        updateDoneButton()
    }

    func didTapNone() {
        selectedSet.removeAll()
        isDoneButtonEnabled = true
    }

    func didTapConcept(at index: Int) {
        if selectedSet.contains(index) {
            selectedSet.remove(index)
        } else {
            selectedSet.insert(index)
        }
        updateDoneButton()
    }

    func didTapDone() {
        guard isDoneButtonEnabled, !isLoading else { return }
        isLoading = true
        let destination: CheckConceptNavigation = selectedSet.isEmpty ? .greeting : .previewTest
        Task { await sendSurvey(navigateTo: destination) }
    }

    // MARK: - Private

    private var totalConceptCount: Int {
        sections.reduce(0) { $0 + $1.range.count }
    }

    private func updateDoneButton() {
        isDoneButtonEnabled = !selectedSet.isEmpty
    }

    private func sendSurvey(navigateTo destination: CheckConceptNavigation) async {
        defer { isLoading = false }
        do {
            let keyConcepts = selectedSet.map { title(for: $0) }
            _ = try await onboardingService.sendSurvey(keyConcepts: keyConcepts)
            userInfo.previewTestStatus = .surveyCompleted
            onNavigate(destination)
        } catch {
            errorMessage = "잠시 후 다시 시도해주세요."
        }
    }
}
