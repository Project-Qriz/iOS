//
//  DailyTestViewModel.swift
//  QRIZ
//
//  Created by 이창현 on 4/1/25.
//

import Foundation
import Combine

final class DailyTestViewModel {
    
    // MARK: - Input & Output
    enum Input {
        case viewDidLoad
        case viewDidAppear
        case optionTapped(optionIdx: Int)
        case cancelButtonClicked
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
        case setButtonVisibility(isVisible: Bool)
        case alterButtonText
        case moveToDailyResult(type: DailyLearnType, day: Int)
        case moveToHomeView
        case popSubmitAlert
        case cancelAlert
        case submitSuccess
        case submitFailed
    }
    
    // MARK: - Properties
    
    private var questionList: [QuestionData] = []
    private var submitData: [DailySubmitData] = []
    private var dailyTestList: [DailyTestInfo] = []
    private var curNum: Int? = nil
    private var timer: Timer? = nil
    private var timeLimit: Int? = nil
    private var startTime: Date? = nil
    private var timeRemaining: Int = 0
    private let dailyTestType: DailyLearnType
    private let day: Int
    
    private let output: PassthroughSubject<Output, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    private let dailyService: DailyService
    
    // MARK: - Initializers
    init(dailyTestType: DailyLearnType, day: Int, dailyService: DailyService) {
        self.dailyTestType = dailyTestType
        self.day = day
        self.dailyService = dailyService
    }
    
    // MARK: - Deinitializer
    deinit {
        exitTimer()
        print("DEINIT: DailyTestViewModel")
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
                if let curNum = curNum, curNum == 1 { buttonStateHandler() }
            case .cancelButtonClicked:
                exitTimer()
                output.send(.moveToHomeView)
            case .nextButtonClicked:
                buttonClickEventHandler()
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
        Task { [weak self] in
            guard let self = self else { return }
            do {
                let response = try await dailyService.getDailyTestList(dayNumber: day)
                guard let data = response.data else { throw NetworkError.unknownError }
                if data.count == 0 { throw NetworkError.unknownError }
                dailyTestList = data
                data.enumerated().forEach {
                    questionList.append(QuestionData(question: $1.question,
                                                     option1: $1.options[0].content,
                                                     option2: $1.options[1].content,
                                                     option3: $1.options[2].content,
                                                     option4: $1.options[3].content,
                                                     timeLimit: $1.timeLimit,
                                                     questionNumber: $0 + 1,
                                                     description: $1.description))
                    submitData.append(
                        DailySubmitData(
                            question: SubmitQuestionData(questionId: $1.questionId, category: $1.category),
                            questionNum: $0 + 1,
                            optionId: nil, timeSpent: 0))
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
    
    private func questionStateHandler() {
        guard let curNum = curNum else { return }
        if curNum > questionList.count {
            sendSubmitData()
            return
        }
        output.send(.updateQuestion(question: questionList[curNum - 1]))
        resetTimer()
        buttonStateHandler()
        deselectAllOptions()
    }
    
    private func optionSelectHandler(optionIdx: Int) {
        guard let curNum = curNum else { return }
        if let prevSelectedIdx = questionList[curNum - 1].selectedOption {
            questionList[curNum - 1].selectedOption = nil
            submitData[curNum - 1].optionId = nil
            output.send(.updateOptionState(optionIdx: prevSelectedIdx, isSelected: false))
            if prevSelectedIdx != optionIdx {
                questionList[curNum - 1].selectedOption = optionIdx
                submitData[curNum - 1].optionId = dailyTestList[curNum - 1].options[optionIdx - 1].id
                output.send(.updateOptionState(optionIdx: optionIdx, isSelected: true))
            }
        } else {
            questionList[curNum - 1].selectedOption = optionIdx
            submitData[curNum - 1].optionId = dailyTestList[curNum - 1].options[optionIdx - 1].id
            output.send(.updateOptionState(optionIdx: optionIdx, isSelected: true))
        }
        
        if curNum == 1 { buttonStateHandler() }
    }
    
    private func buttonStateHandler() {
        guard let curNum = curNum else { return }
        switch curNum {
        case 1:
            if let _ = questionList[0].selectedOption {
                output.send(.setButtonVisibility(isVisible: true))
            } else {
                output.send(.setButtonVisibility(isVisible: false))
            }
        case 2:
            output.send(.setButtonVisibility(isVisible: true))
        case questionList.count:
            output.send(.alterButtonText)
        default:
            return
        }
    }
    
    private func buttonClickEventHandler() {
        guard let currentNumber = curNum else { return }
        if currentNumber >= questionList.count {
            output.send(.popSubmitAlert)
        } else {
            curNum = currentNumber + 1
            questionStateHandler()
        }
    }
    
    private func deselectAllOptions() {
        for idx in 1...4 {
            output.send(.updateOptionState(optionIdx: idx, isSelected: false))
        }
    }
    
    private func sendSubmitData() {
        Task { [weak self] in
            guard let self = self else { return }
            do {
                let _ = try await dailyService.submitDaily(dayNumber: day, dailySubmitData: submitData)
                exitTimer()
                output.send(.submitSuccess)
                output.send(.moveToDailyResult(type: dailyTestType, day: day))
            } catch {
                output.send(.submitFailed)
            }
        }
    }
}

// MARK: - Timer Methods
extension DailyTestViewModel {
    private func startTimer() {
        startTime = Date()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimerPerSecond), userInfo: nil, repeats: true)
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    @objc func updateTimerPerSecond() {
        guard let timeLimit = timeLimit, let startTime = startTime else { return }
        let timeElapsed = Int(Date().timeIntervalSince(startTime))
        timeRemaining = timeLimit - timeElapsed
        if timeRemaining >= 0 {
            output.send(.updateTime(timeLimit: timeLimit, timeRemaining: timeRemaining))
        } else {
            guard let currentNumber = curNum else { return }
            curNum = currentNumber + 1
            questionStateHandler()
        }
    }
    
    private func resetTimer() {
        guard let curNum = curNum else { return }
        if curNum >= 2 {
            submitData[curNum - 2].timeSpent = questionList[curNum - 2].timeLimit - timeRemaining
        }
        // 기존 타이머는 1초마다 감지하기 때문에 문제 변경 시 즉각적인 타이머 변경을 위한 로직 추가
        startTime = Date()
        timeLimit = questionList[curNum - 1].timeLimit
        if let timeLimit = timeLimit {
            timeRemaining = timeLimit
            output.send(.updateTime(timeLimit: timeLimit, timeRemaining: timeRemaining))
        }
    }

    private func exitTimer() {
        timer?.invalidate()
        timer = nil
        print("EXIT TIMER")
    }
}
