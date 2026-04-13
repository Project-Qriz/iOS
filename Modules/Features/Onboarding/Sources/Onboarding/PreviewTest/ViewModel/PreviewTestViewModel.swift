import Foundation
import Combine
import Network
import QRIZUtils

private struct PreviewQuestion {
    let data: PreviewTestListQuestion
    var selectedOptionIdx: Int?   // 선택된 옵션 번호 (1-based), nil이면 미선택
    var submitOptionId: Int?      // 제출 시 사용할 option ID
}

@MainActor
final class PreviewTestViewModel {

    // MARK: - Input & Output

    enum Input {
        case viewDidLoad
        case optionTapped(Int)
        case prevTapped
        case nextTapped
        case escapeTapped
        case confirmSubmit
        case cancelSubmit
        case retrySubmit
    }

    enum Output {
        case updateQuestion(question: QuestionData, selectedOption: Int?)
        case updateTotalNum(Int)
        case updateTime(timeLimit: Int, timeRemaining: Int)
        case updateOptionState(idx: Int, isSelected: Bool)
        case updateButtonStates(prevHidden: Bool, nextHidden: Bool, nextTitle: String)
        case showSubmitAlert
        case dismissSubmitAlert
        case showSubmitRetryAlert
        case showError(String)
        case navigateToResult
        case navigateToHome
    }

    // MARK: - Properties

    private var questions: [PreviewQuestion] = []
    private var currentIndex: Int = 0   // 0-based 현재 문제 인덱스
    private var countdownTimer: CountdownTimer?
    private var isSubmitting: Bool = false

    private let output = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()

    private let onboardingService: OnboardingService

    // MARK: - Initializer

    init(onboardingService: OnboardingService) {
        self.onboardingService = onboardingService
    }

    deinit {
        MainActor.assumeIsolated {
            countdownTimer?.stop()
        }
    }

    // MARK: - Methods

    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            guard let self else { return }
            switch event {
            case .viewDidLoad:
                Task { await self.fetchQuestions() }
            case .optionTapped(let idx):
                handleOptionTap(idx)
            case .prevTapped:
                navigatePage(offset: -1)
            case .nextTapped:
                handleNextTap()
            case .escapeTapped:
                countdownTimer?.stop()
                output.send(.navigateToHome)
            case .confirmSubmit:
                guard !self.isSubmitting else { return }
                self.isSubmitting = true
                Task { await self.submit() }
            case .cancelSubmit:
                output.send(.dismissSubmitAlert)
            case .retrySubmit:
                guard !self.isSubmitting else { return }
                self.isSubmitting = true
                Task { await self.submit() }
            }
        }
        .store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
}

// MARK: - Private

private extension PreviewTestViewModel {

    func handleOptionTap(_ idx: Int) {
        let prev = questions[currentIndex].selectedOptionIdx

        if let prev {
            output.send(.updateOptionState(idx: prev, isSelected: false))
        }

        if prev == idx {
            questions[currentIndex].selectedOptionIdx = nil
            questions[currentIndex].submitOptionId = nil
        } else {
            questions[currentIndex].selectedOptionIdx = idx
            questions[currentIndex].submitOptionId = questions[currentIndex].data.options[idx - 1].id
            output.send(.updateOptionState(idx: idx, isSelected: true))
        }

        if currentIndex == 0 {
            sendButtonStates(index: 0, selectedOption: questions[0].selectedOptionIdx)
        }
    }

    func handleNextTap() {
        if currentIndex >= questions.count - 1 {
            output.send(.showSubmitAlert)
        } else {
            navigatePage(offset: 1)
        }
    }

    func navigatePage(offset: Int) {
        let newIndex = currentIndex + offset
        guard newIndex >= 0, newIndex < questions.count else { return }
        currentIndex = newIndex
        let selectedOption = questions[currentIndex].selectedOptionIdx

        output.send(.updateQuestion(
            question: toQuestionData(from: questions[currentIndex].data, questionNumber: currentIndex + 1),
            selectedOption: selectedOption
        ))
        sendButtonStates(index: currentIndex, selectedOption: selectedOption)
    }

    func sendButtonStates(index: Int, selectedOption: Int?) {
        let isFirst = index == 0
        let isLast = index == questions.count - 1
        output.send(.updateButtonStates(
            prevHidden: isFirst,
            nextHidden: isFirst && selectedOption == nil,
            nextTitle: isLast ? "제출" : "다음"
        ))
    }

    func fetchQuestions() async {
        do {
            let response = try await onboardingService.getPreviewTestList()
            let rawQuestions = response.data.questions
            guard !rawQuestions.isEmpty else { return }

            currentIndex = 0
            questions = rawQuestions.map { PreviewQuestion(data: $0) }

            output.send(.updateTotalNum(rawQuestions.count))
            output.send(.updateQuestion(question: toQuestionData(from: questions[0].data, questionNumber: 1), selectedOption: nil))
            sendButtonStates(index: 0, selectedOption: nil)

            let totalTimeLimit = response.data.totalTimeLimit
            let timer = CountdownTimer(totalTime: totalTimeLimit)
            countdownTimer = timer
            timer.remainingTimePublisher
                .sink { [weak self] remaining in
                    guard let self else { return }
                    output.send(.updateTime(timeLimit: totalTimeLimit, timeRemaining: remaining))
                    if remaining == 0 {
                        guard !isSubmitting else { return }
                        isSubmitting = true
                        Task { await self.submit() }
                    }
                }
                .store(in: &cancellables)
            timer.start()
        } catch {
            output.send(.showError("문제 불러오기 실패"))
        }
    }

    func toQuestionData(from question: PreviewTestListQuestion, questionNumber: Int) -> QuestionData {
        QuestionData(
            question: question.question,
            option1: question.options[0].content,
            option2: question.options[1].content,
            option3: question.options[2].content,
            option4: question.options[3].content,
            optionContentTypes: question.options.map { $0.contentType },
            timeLimit: question.timeLimit,
            questionNumber: questionNumber,
            description: question.description,
            skillId: question.skillId
        )
    }

    func submit() async {
        countdownTimer?.stop()

        let submitList = questions.enumerated().map { idx, q in
            TestSubmitData(
                question: SubmitQuestionData(questionId: q.data.questionId, category: q.data.category),
                questionNum: idx + 1,
                optionId: q.submitOptionId
            )
        }
        do {
            _ = try await onboardingService.submitPreview(testSubmitDataList: submitList)
            output.send(.dismissSubmitAlert)
            output.send(.navigateToResult)
        } catch {
            isSubmitting = false
            output.send(.dismissSubmitAlert)
            output.send(.showSubmitRetryAlert)
        }
    }
}
