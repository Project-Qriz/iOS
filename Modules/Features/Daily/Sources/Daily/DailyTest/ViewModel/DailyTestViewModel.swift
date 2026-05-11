//
//  DailyTestViewModel.swift
//  QRIZ
//
//  Created by 이창현 on 4/1/25.
//

import Foundation
import Combine
import QRIZUtils
import QRIZNetwork

@MainActor
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
        case moveToDailyResult
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
    private var curNum: Int?
    private var timer: Timer?
    private var timeLimit: Int?
    private var startTime: Date?
    private var timeRemaining: Int = 0
    private let day: Int
    
    private let output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    private let dailyService: DailyService
    private let analyticsService: any AnalyticsService

    // MARK: - Initializers

    init(
        day: Int,
        dailyService: DailyService,
        analyticsService: any AnalyticsService = AnalyticsManager.shared
    ) {
        self.day = day
        self.dailyService = dailyService
        self.analyticsService = analyticsService
    }
    
    // MARK: - Deinitializer
    
    deinit {
        timer?.invalidate()
    }
    
    // MARK: - Methods
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            guard let self else { return }
            switch event {
            case .viewDidLoad:
                fetchData()
            case .viewDidAppear:
                startTimer()
            case .optionTapped(let optionIdx):
                optionSelectHandler(optionIdx: optionIdx)
            case .cancelButtonClicked:
                exitTimer()
                output.send(.moveToHomeView)
            case .nextButtonClicked:
                handleNextButton()
            case .alertSubmitButtonClicked:
                sendSubmitData()
            case .alertCancelButtonClicked:
                output.send(.cancelAlert)
            }
        }
        .store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
    private func fetchData() {
        Task { [weak self] in
            guard let self else { return }
            do {
                let response = try await dailyService.getDailyTestList(dayNumber: day)
                guard let data = response.data else { throw NetworkError.unknownError }
                if data.isEmpty { throw NetworkError.unknownError }
                dailyTestList = data
                data.enumerated().forEach { index, item in
                    guard item.options.count >= 4 else { return }
                    self.questionList.append(QuestionData(
                        question: item.question,
                        option1: item.options[0].content,
                        option2: item.options[1].content,
                        option3: item.options[2].content,
                        option4: item.options[3].content,
                        optionContentTypes: item.options.map { $0.contentType },
                        timeLimit: item.timeLimit,
                        questionNumber: index + 1,
                        description: item.description
                    ))
                    self.submitData.append(DailySubmitData(
                        question: SubmitQuestionData(questionId: item.questionId, category: item.category),
                        questionNum: index + 1,
                        optionId: nil,
                        timeSpent: 0
                    ))
                }
                curNum = 1
                output.send(.updateTotalPage(totalPage: questionList.count))
                questionStateHandler()
            } catch NetworkError.serverError(_) {
                output.send(.fetchFailed(isServerError: true))
            } catch {
                output.send(.fetchFailed(isServerError: false))
            }
        }
    }
    
    private func questionStateHandler() {
        guard let curNum else { return }
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
        guard let curNum else { return }
        guard optionIdx - 1 < dailyTestList[curNum - 1].options.count else { return }
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
        guard let curNum else { return }
        switch curNum {
        case 1:
            output.send(.setButtonVisibility(isVisible: questionList[0].selectedOption != nil))
        case 2:
            output.send(.setButtonVisibility(isVisible: true))
        case questionList.count:
            output.send(.alterButtonText)
        default:
            return
        }
    }
    
    private func handleNextButton() {
        guard let curNum else { return }
        if curNum >= questionList.count {
            output.send(.popSubmitAlert)
        } else {
            self.curNum = curNum + 1
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
            guard let self else { return }
            do {
                try await dailyService.submitDaily(dayNumber: day, dailySubmitData: submitData)
                exitTimer()
                analyticsService.log(.dailyComplete)
                output.send(.submitSuccess)
                output.send(.moveToDailyResult)
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
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.updateTimerPerSecond()
            }
        }
        if let timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    private func updateTimerPerSecond() {
        guard let timeLimit, let startTime else { return }
        let timeElapsed = Int(Date().timeIntervalSince(startTime))
        timeRemaining = timeLimit - timeElapsed
        if timeRemaining >= 0 {
            output.send(.updateTime(timeLimit: timeLimit, timeRemaining: timeRemaining))
        } else {
            guard let curNum else { return }
            self.curNum = curNum + 1
            questionStateHandler()
        }
    }
    
    private func resetTimer() {
        guard let curNum else { return }
        if curNum >= 2 {
            submitData[curNum - 2].timeSpent = questionList[curNum - 2].timeLimit - timeRemaining
        }
        // 기존 타이머는 1초마다 감지하기 때문에 문제 변경 시 즉각적인 타이머 변경을 위한 로직 추가
        startTime = Date()
        timeLimit = questionList[curNum - 1].timeLimit
        if let timeLimit {
            timeRemaining = timeLimit
            output.send(.updateTime(timeLimit: timeLimit, timeRemaining: timeRemaining))
        }
    }
    
    private func exitTimer() {
        timer?.invalidate()
        timer = nil
    }
}
