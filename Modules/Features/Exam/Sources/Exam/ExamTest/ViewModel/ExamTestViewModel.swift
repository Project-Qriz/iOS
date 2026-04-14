import Foundation
import Combine
import QRIZUtils
import Network

@MainActor
final class ExamTestViewModel {

    // MARK: - Properties

    private let examId: Int
    private let examService: any ExamService
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()

    private var questionList: [QuestionData] = []
    private var submitData: [TestSubmitData] = []
    private var examQuestionList: [ExamQuestionInfo] = []
    private var curNum: Int?
    private var timeLimit: Int?
    private var countdown: CountdownTimer?
    private var isSubmitting = false
    private var didAppear = false

    // MARK: - Initialization

    private let analyticsService: any AnalyticsService

    init(
        examId: Int,
        examService: any ExamService,
        analyticsService: any AnalyticsService = AnalyticsManager.shared
    ) {
        self.examId = examId
        self.examService = examService
        self.analyticsService = analyticsService
    }

    // MARK: - Methods

    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink { [weak self] event in
                guard let self else { return }
                switch event {
                case .viewDidLoad:
                    fetchData()

                case .viewDidAppear:
                    didAppear = true
                    countdown?.start()

                case .didTapOption(let optionIdx):
                    handleOptionSelect(optionIdx: optionIdx)

                case .didTapCancelButton:
                    analyticsService.log(.examAbandon)
                    countdown?.stop()
                    outputSubject.send(.moveToExamList)

                case .didTapPrevButton:
                    handleButtonClick(isNextButton: false)

                case .didTapNextButton:
                    handleButtonClick(isNextButton: true)

                case .didTapAlertSubmit:
                    sendSubmitData()

                case .didTapAlertCancel:
                    outputSubject.send(.cancelAlert)
                }
            }
            .store(in: &cancellables)

        return outputSubject.eraseToAnyPublisher()
    }

    private func fetchData() {
        Task { [weak self] in
            guard let self else { return }
            do {
                let response = try await examService.getExamQuestion(examId: examId)
                let data = response.data
                if data.questions.isEmpty { throw NetworkError.unknownError }
                examQuestionList = data.questions
                timeLimit = data.totalTimeLimit
                for (index, question) in data.questions.enumerated() {
                    guard question.options.count >= 4 else { throw NetworkError.unknownError }
                    questionList.append(QuestionData(
                        question: question.question,
                        option1: question.options[0].content,
                        option2: question.options[1].content,
                        option3: question.options[2].content,
                        option4: question.options[3].content,
                        optionContentTypes: question.options.map { $0.contentType },
                        timeLimit: question.timeLimit,
                        questionNumber: index + 1,
                        description: question.description
                    ))
                    submitData.append(TestSubmitData(
                        question: SubmitQuestionData(questionId: question.questionId, category: question.category),
                        questionNum: index + 1,
                        optionId: nil
                    ))
                }
                curNum = 1
                outputSubject.send(.updateTotalPage(totalPage: questionList.count))
                updateQuestionState()
                setupCountdown(totalTime: data.totalTimeLimit)
                analyticsService.log(.examStart)

            } catch NetworkError.serverError(_) {
                outputSubject.send(.fetchFailed(isServerError: true))

            } catch {
                outputSubject.send(.fetchFailed(isServerError: false))
            }
        }
    }

    private func setupCountdown(totalTime: Int) {
        countdown = CountdownTimer(totalTime: totalTime)
        countdown?.remainingTimePublisher
            .sink { [weak self] remaining in
                guard let self, let timeLimit else { return }
                outputSubject.send(.updateTime(timeLimit: timeLimit, timeRemaining: remaining))
                if remaining <= 0 {
                    sendSubmitData()
                }
            }
            .store(in: &cancellables)
        if didAppear {
            countdown?.start()
        }
    }

    private func sendSubmitData() {
        guard !isSubmitting else { return }
        isSubmitting = true
        Task { [weak self] in
            guard let self else { return }
            do {
                try await examService.submitTest(examId: examId, testSubmitData: submitData)
                countdown?.stop()
                outputSubject.send(.submitSuccess)
                outputSubject.send(.moveToExamResult(examId: examId))

            } catch {
                isSubmitting = false
                outputSubject.send(.submitFailed)
            }
        }
    }

    private func handleOptionSelect(optionIdx: Int) {
        guard let curNum, curNum >= 1, curNum <= questionList.count else { return }
        let idx = curNum - 1

        if let prevSelectedIdx = questionList[idx].selectedOption {
            questionList[idx].selectedOption = nil
            submitData[idx].optionId = nil
            outputSubject.send(.updateOptionState(optionIdx: prevSelectedIdx, isSelected: false))
            if prevSelectedIdx != optionIdx {
                questionList[idx].selectedOption = optionIdx
                submitData[idx].optionId = examQuestionList[idx].options[optionIdx - 1].id
                outputSubject.send(.updateOptionState(optionIdx: optionIdx, isSelected: true))
            }
        } else {
            questionList[idx].selectedOption = optionIdx
            submitData[idx].optionId = examQuestionList[idx].options[optionIdx - 1].id
            outputSubject.send(.updateOptionState(optionIdx: optionIdx, isSelected: true))
        }

        if curNum == 1 {
            outputSubject.send(.updateNextButton(
                isVisible: questionList[0].selectedOption != nil,
                isTextSubmit: false
            ))
        }
    }

    private func handleButtonClick(isNextButton: Bool) {
        guard let curNum, curNum >= 1, curNum <= questionList.count else { return }

        if curNum == questionList.count && isNextButton {
            outputSubject.send(.popSubmitAlert)
            return
        }

        self.curNum = curNum + (isNextButton ? 1 : -1)
        updateQuestionState()
    }

    private func updateQuestionState() {
        guard let curNum, curNum >= 1, curNum <= questionList.count else { return }
        outputSubject.send(.updateQuestion(question: questionList[curNum - 1]))
        if let optionIdx = questionList[curNum - 1].selectedOption {
            outputSubject.send(.updateOptionState(optionIdx: optionIdx, isSelected: true))
        }
        updateNavigationButtonState()
    }

    private func updateNavigationButtonState() {
        guard let curNum, curNum >= 1, curNum <= questionList.count else { return }

        switch curNum {
        case 1:
            outputSubject.send(.updatePrevButton(isVisible: false))
            outputSubject.send(.updateNextButton(
                isVisible: questionList[curNum - 1].selectedOption != nil,
                isTextSubmit: false
            ))
        default:
            outputSubject.send(.updatePrevButton(isVisible: true))
            outputSubject.send(.updateNextButton(
                isVisible: true,
                isTextSubmit: curNum == questionList.count
            ))
        }
    }
}

extension ExamTestViewModel {
    enum Input {
        case viewDidLoad
        case viewDidAppear
        case didTapOption(optionIdx: Int)
        case didTapCancelButton
        case didTapPrevButton
        case didTapNextButton
        case didTapAlertSubmit
        case didTapAlertCancel
    }

    enum Output {
        case fetchFailed(isServerError: Bool)
        case updateQuestion(question: QuestionData)
        case updateTotalPage(totalPage: Int)
        case updateTime(timeLimit: Int, timeRemaining: Int)
        case updateOptionState(optionIdx: Int, isSelected: Bool)
        case updatePrevButton(isVisible: Bool)
        case updateNextButton(isVisible: Bool, isTextSubmit: Bool)
        case moveToExamResult(examId: Int)
        case moveToExamList
        case popSubmitAlert
        case cancelAlert
        case submitSuccess
        case submitFailed
    }
}
