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
    }

    enum Output {
        case updateQuestion(question: PreviewTestListQuestion, curNum: Int, selectedOption: Int?)
        case updateTotalNum(Int)
        case updateTime(timeLimit: Int, timeRemaining: Int)
        case updateOptionState(idx: Int, isSelected: Bool)
        case setPrevButtonHidden(Bool)
        case setNextButtonHidden(Bool)
        case setNextButtonTitle(isLastQuestion: Bool)
        case showSubmitAlert
        case dismissSubmitAlert
        case showError(String)
        case navigateToResult
        case navigateToHome
    }

    // MARK: - Properties

    private var questions: [PreviewQuestion] = []
    private var currentIndex: Int = 0   // 0-based 현재 문제 인덱스
    private var countdownTimer: CountdownTimer?
    private var isSubmitting: Bool = false
    private var timeLimit: Int = 0

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
                Task { await self.submit() }
            case .cancelSubmit:
                output.send(.dismissSubmitAlert)
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
            output.send(.setNextButtonHidden(questions[0].selectedOptionIdx == nil))
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
        currentIndex += offset
        let selectedOption = questions[currentIndex].selectedOptionIdx

        output.send(.updateQuestion(
            question: questions[currentIndex].data,
            curNum: currentIndex + 1,
            selectedOption: selectedOption
        ))
        sendButtonStates(curNum: currentIndex + 1, selectedOption: selectedOption)
    }

    func sendButtonStates(curNum: Int, selectedOption: Int?) {
        let isFirst = curNum == 1
        let isLast = curNum == questions.count
        output.send(.setPrevButtonHidden(isFirst))
        output.send(.setNextButtonHidden(isFirst && selectedOption == nil))
        output.send(.setNextButtonTitle(isLastQuestion: isLast))
    }

    func fetchQuestions() async {
        do {
            let response = try await onboardingService.getPreviewTestList()
            let rawQuestions = response.data.questions
            guard !rawQuestions.isEmpty else { return }

            currentIndex = 0
            timeLimit = response.data.totalTimeLimit
            questions = rawQuestions.map { PreviewQuestion(data: $0) }

            output.send(.updateTotalNum(rawQuestions.count))
            output.send(.updateQuestion(question: questions[0].data, curNum: 1, selectedOption: nil))
            sendButtonStates(curNum: 1, selectedOption: nil)
            let timer = CountdownTimer(totalTime: response.data.totalTimeLimit)
            countdownTimer = timer
            timer.remainingTimePublisher
                .sink { [weak self] remaining in
                    guard let self else { return }
                    output.send(.updateTime(timeLimit: timeLimit, timeRemaining: remaining))
                    if remaining == 0 {
                        guard !isSubmitting else { return }
                        Task { await self.submit() }
                    }
                }
                .store(in: &cancellables)
            timer.start()
        } catch {
            output.send(.showError("문제 불러오기 실패"))
        }
    }

    func submit() async {
        guard !isSubmitting else { return }
        isSubmitting = true
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
            output.send(.showError("잠시 후 다시 시도해주세요."))
        }
    }


}
