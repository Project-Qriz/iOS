//
//  ExamTestViewModel.swift
//  QRIZ
//
//  Created by ch on 5/21/25.
//

import Foundation
import Combine

final class ExamTestViewModel {
    
    // MARK: Input & Output
    enum Input {
        case viewDidLoad
        case viewDidAppear
        case optionTapped(optionIdx: Int)
        case cancelButtonClicked
        case prevButtonClicked
        case nextButtonClicked
        case alertSubmitButtonClicked
        case alertCancelButtonClicked
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
    
    // MARK: - Properties
    private var questionList: [QuestionData] = []
    private var submitData: [TestSubmitData] = []
    private var examQuestionList: [ExamQuestionInfo] = []
    private var curNum: Int? = nil
    private var timer: Timer? = nil
    private var timeLimit: Int? = nil
    private var startTime: Date? = nil
    private let examId: Int
    
    private let output: PassthroughSubject<Output, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    private let examService: ExamService
    
    // MARK: - Initializer
    init(examId: Int, examService: ExamService) {
        self.examId = examId
        self.examService = examService
    }
    
    // MARK: - Deinitializer
    deinit {
        exitTimer()
        print("DEINIT: ExamTestViewModel")
    }
    
    // MARK: - Methods
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .viewDidLoad:
                fetchData()
            case .viewDidAppear:
                startTimer()
            case .optionTapped(let optionIdx):
                optionSelectHandler(optionIdx: optionIdx)
            case .cancelButtonClicked:
                exitTimer()
                output.send(.moveToExamList)
            case .prevButtonClicked:
                buttonClickEventHandler(isNextButton: false)
            case .nextButtonClicked:
                buttonClickEventHandler(isNextButton: true)
            case .alertSubmitButtonClicked:
                sendSubmitData()
            case .alertCancelButtonClicked:
                output.send(.cancelAlert)
            }
        }
        .store(in: &subscriptions)
        return output.eraseToAnyPublisher()
    }
    
    private func fetchData() {
        Task {
            do {
                let response = try await examService.getExamQuestion(examId: examId)
                let data = response.data
                if data.questions.count == 0 { throw NetworkError.unknownError }
                examQuestionList = data.questions
                timeLimit = data.totalTimeLimit
                data.questions.enumerated().forEach {
                    questionList.append(QuestionData(question: $1.question,
                                                     option1: $1.options[0].content,
                                                     option2: $1.options[1].content,
                                                     option3: $1.options[2].content,
                                                     option4: $1.options[3].content,
                                                     timeLimit: $1.timeLimit,
                                                     questionNumber: $0 + 1,
                                                     description: $1.description))
                    submitData.append(
                        TestSubmitData(question: SubmitQuestionData(questionId: $1.questionId, category: $1.category),
                                       questionNum: $0 + 1,
                                       optionId: nil))
                }
                curNum = 1
                output.send(.updateTotalPage(totalPage: questionList.count))
                questionStateHandler()
            } catch NetworkError.serverError {
                output.send(.fetchFailed(isServerError: true))
            } catch {
                output.send(.fetchFailed(isServerError: false))
            }
        }
    }
    
    private func sendSubmitData() {
        Task {
            do {
                let _ = try await examService.submitTest(examId: examId, testSubmitData: submitData)
                exitTimer()
                output.send(.submitSuccess)
                output.send(.moveToExamResult(examId: examId))
            } catch NetworkError.serverError {
                output.send(.fetchFailed(isServerError: true))
            } catch {
                output.send(.fetchFailed(isServerError: false))
            }
        }
    }
    
    private func questionStateHandler() {
        guard let curNum = curNum, curNum >= 1, curNum <= questionList.count else { return }
        output.send(.updateQuestion(question: questionList[curNum - 1]))
        if let optionIdx = questionList[curNum - 1].selectedOption {
            output.send(.updateOptionState(optionIdx: optionIdx, isSelected: true))
        }
        questionButtonStateHandler()
    }
    
    private func optionSelectHandler(optionIdx: Int) {
        guard let curNum = curNum, curNum >= 1, curNum <= questionList.count else { return }

        if let prevSelectedIdx = questionList[curNum - 1].selectedOption {
            questionList[curNum - 1].selectedOption = nil
            submitData[curNum - 1].optionId = nil
            output.send(.updateOptionState(optionIdx: prevSelectedIdx, isSelected: false))
            if prevSelectedIdx != optionIdx {
                questionList[curNum - 1].selectedOption = optionIdx
                submitData[curNum - 1].optionId = examQuestionList[curNum - 1].options[optionIdx - 1].id
                output.send(.updateOptionState(optionIdx: optionIdx, isSelected: true))
            }
        } else {
            questionList[curNum - 1].selectedOption = optionIdx
            submitData[curNum - 1].optionId = examQuestionList[curNum - 1].options[optionIdx - 1].id
            output.send(.updateOptionState(optionIdx: optionIdx, isSelected: true))
        }

        optionSelectButtonStateHandler()
    }
    
    // 버튼 눌렀을 때에 대한 로직 관리
    private func buttonClickEventHandler(isNextButton: Bool) {
        guard let curNum = curNum, curNum >= 1, curNum <= questionList.count else { return }
        
        if curNum == questionList.count && isNextButton {
            output.send(.popSubmitAlert)
            return
        }
        
        let diff = isNextButton ? 1 : -1
        self.curNum = curNum + diff
        questionStateHandler()
    }
    
    // 문제 번호에 따라 정해지는 버튼 상태 관리
    private func questionButtonStateHandler() {
        guard let curNum = curNum, curNum >= 1, curNum <= questionList.count else { return }
        
        switch curNum {
        case 1:
            output.send(.updatePrevButton(isVisible: false))
            if questionList[curNum - 1].selectedOption == nil {
                output.send(.updateNextButton(isVisible: false, isTextSubmit: false))
            } else {
                output.send(.updateNextButton(isVisible: true, isTextSubmit: false))
            }
        case questionList.count:
            output.send(.updateNextButton(isVisible: true, isTextSubmit: true))
        default:
            output.send(.updatePrevButton(isVisible: true))
            output.send(.updateNextButton(isVisible: true, isTextSubmit: false))
        }
    }
    
    // 옵션을 누르면서 정해지는 버튼 상태 관리
    private func optionSelectButtonStateHandler() {
        guard let curNum = curNum, curNum >= 1, curNum <= questionList.count else { return }
        
        if curNum == 1 {
            if questionList[curNum - 1].selectedOption == nil {
                output.send(.updateNextButton(isVisible: false, isTextSubmit: false))
            } else {
                output.send(.updateNextButton(isVisible: true, isTextSubmit: false))
            }
        }
    }
}

// MARK: - Timer Methods
extension ExamTestViewModel {
    private func startTimer() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            startTime = Date()
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimerPerSecond), userInfo: nil, repeats: true)
            if let timer = timer {
                RunLoop.main.add(timer, forMode: .common)
            }
        }
    }
    
    @objc private func updateTimerPerSecond() {
        guard let timeLimit = timeLimit, let startTime = startTime else { return }
        let timeElapsed = Int(Date().timeIntervalSince(startTime))
        let timeRemaining = timeLimit - timeElapsed
        if timeRemaining >= 0 {
            output.send(.updateTime(timeLimit: timeLimit, timeRemaining: timeRemaining))
        } else {
            sendSubmitData()
        }
    }
    
    private func exitTimer() {
        timer?.invalidate()
        timer = nil
        print("EXIT TIMER")
    }
}
