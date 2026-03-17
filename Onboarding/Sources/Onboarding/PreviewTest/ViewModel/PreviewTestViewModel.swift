import Foundation
import Combine
import QRIZUtils
import Network

@MainActor
final class PreviewTestViewModel: ObservableObject {
    @Published var timeRemaining: Int = 0
    @Published var timeLimit: Int = 0
    @Published var totalNum: Int = 0
    @Published var showSubmitAlert: Bool = false
    @Published var errorMessage: String? = nil

    var onUpdateQuestion: ((_ question: PreviewTestListQuestion, _ curNum: Int, _ selectedOption: Int?) -> Void)?
    var onNavigateToResult: (() -> Void)?
    var onNavigateToHome: (() -> Void)?

    private var questionList: [PreviewTestListQuestion] = []
    private var submitList: [TestSubmitData] = []
    private var selectedList: [Int?] = []
    private var currentNumber: Int? = nil
    private var timer: Timer?
    private var startTime: Date?

    private let onboardingService: OnboardingService

    init(onboardingService: OnboardingService) {
        self.onboardingService = onboardingService
    }

    deinit {
        timer?.invalidate()
    }

    func onViewDidLoad() {
        Task { await fetchQuestions() }
    }

    func didTapPrev(selectedOption: Int?) {
        updateAnswer(selectedOption: selectedOption)
        navigatePage(offset: -1)
    }

    func didTapNext(selectedOption: Int?) {
        updateAnswer(selectedOption: selectedOption)
        guard let curNum = currentNumber else { return }
        if curNum >= questionList.count {
            showSubmitAlert = true
        } else {
            navigatePage(offset: 1)
        }
    }

    func didTapEscape() {
        stopTimer()
        onNavigateToHome?()
    }

    func didConfirmSubmit() {
        Task { await submit() }
    }

    func didCancelSubmit() {
        showSubmitAlert = false
    }

    private func updateAnswer(selectedOption: Int?) {
        guard let currentNumber else { return }
        selectedList[currentNumber - 1] = selectedOption
        if let opt = selectedOption {
            submitList[currentNumber - 1].optionId = questionList[currentNumber - 1].options[opt - 1].id
        } else {
            submitList[currentNumber - 1].optionId = nil
        }
    }

    private func navigatePage(offset: Int) {
        guard let curNum = currentNumber else { return }
        currentNumber = curNum + offset
        let idx = currentNumber! - 1
        onUpdateQuestion?(questionList[idx], currentNumber!, selectedList[idx])
    }

    private func submit() async {
        do {
            _ = try await onboardingService.submitPreview(testSubmitDataList: submitList)
            stopTimer()
            showSubmitAlert = false
            onNavigateToResult?()
        } catch {
            showSubmitAlert = false
            errorMessage = "잠시 후 다시 시도해주세요."
        }
    }

    private func fetchQuestions() async {
        do {
            let response = try await onboardingService.getPreviewTestList()
            let questions = response.data.questions
            guard !questions.isEmpty else { return }
            currentNumber = 1
            totalNum = questions.count
            timeLimit = response.data.totalTimeLimit
            questionList = questions
            initSubmitList(response)
            selectedList = Array(repeating: nil, count: questions.count)
            startTimerPublishing(totalTimeLimit: response.data.totalTimeLimit)
            onUpdateQuestion?(questionList[0], 1, nil)
        } catch {
            errorMessage = "문제 불러오기 실패"
        }
    }

    private func initSubmitList(_ response: PreviewTestListResponse) {
        response.data.questions.enumerated().forEach { idx, question in
            submitList.append(TestSubmitData(
                question: SubmitQuestionData(questionId: question.questionId, category: question.category),
                questionNum: idx + 1,
                optionId: nil
            ))
        }
    }

    private func startTimerPublishing(totalTimeLimit: Int) {
        timeRemaining = totalTimeLimit
        startTime = Date()
        // @MainActor 클래스에서 #selector 기반 타이머는 strict concurrency 경고 유발.
        // 클로저 기반 타이머 사용.
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tickTimer()
        }
        if let t = timer { RunLoop.main.add(t, forMode: .common) }
    }

    private func tickTimer() {
        guard let start = startTime else { return }
        let elapsed = Int(Date().timeIntervalSince(start))
        let remaining = timeLimit - elapsed
        if remaining >= 0 {
            timeRemaining = remaining
        } else {
            stopTimer()
            Task { await submit() }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
