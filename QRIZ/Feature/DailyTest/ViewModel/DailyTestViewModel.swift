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
//        case alertSubmitButtonClicked
//        case alertCancelButtonClicked
    }
    
    enum Output {
        case fetchFailed
        case updateQuestion(question: QuestionData)
        case updateTotalPage(totalPage: Int)
        case updateTime(timeLimit: Int, timeRemaining: Int)
        case updateOptionState(optionIdx: Int, isSelected: Bool)
        case moveToDailyResult
        case moveToHomeView
//        case submitSuccess
//        case submitFail
//        case cancelSubmit
    }
    
    // MARK: - Properties
    
    private var questionList: [QuestionData] = []
    private var curNum: Int? = nil
    private var timer: Timer? = nil
    private var timeLimit: Int? = nil
    private var startTime: Date? = nil
    
    private let output: PassthroughSubject<Output, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    
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
                curNum = 1
                output.send(.updateTotalPage(totalPage: questionList.count))
                questionStateHandler()
            case .viewDidAppear:
                startTimer()
            case .optionTapped(let optionIdx):
                optionSelectHandler(optionIdx: optionIdx)
            case .cancelButtonClicked:
                exitTimer()
                output.send(.moveToHomeView)
            case .nextButtonClicked:
                guard let currentNumber = curNum else { return }
                if currentNumber >= questionList.count {
                    print("submit alert")
                } else {
                    curNum = currentNumber + 1
                    questionStateHandler()
                }
                for idx in 1...4 {
                    output.send(.updateOptionState(optionIdx: idx, isSelected: false))
                }
//            case .alertSubmitButtonClicked:
//            case .alertCancelButtonClicked:
            }
        }
        .store(in: &subscriptions)
        return output.eraseToAnyPublisher()
    }
    
    private func fetchData() {
        fetchMockData()
    }
    
    private func fetchMockData() {
        questionList = QuestionData.dailySampleList
    }
    
    private func questionStateHandler() {
        guard let curNum = curNum else { return }
        if curNum > questionList.count {
            exitTimer()
            output.send(.moveToDailyResult)
            // submit result here
            return
        }
        output.send(.updateQuestion(question: questionList[curNum - 1]))
        resetTimer()
    }
    
    private func optionSelectHandler(optionIdx: Int) {
        guard let curNum = curNum else { return }
        if let prevSelectedIdx = questionList[curNum - 1].selectedOption {
            questionList[curNum - 1].selectedOption = nil
            output.send(.updateOptionState(optionIdx: prevSelectedIdx, isSelected: false))
            if prevSelectedIdx != optionIdx {
                questionList[curNum - 1].selectedOption = optionIdx
                output.send(.updateOptionState(optionIdx: optionIdx, isSelected: true))
            }
        } else {
            questionList[curNum - 1].selectedOption = optionIdx
            output.send(.updateOptionState(optionIdx: optionIdx, isSelected: true))
        }
    }
}

// MARK: - Timer Methods
extension DailyTestViewModel {
    private func startTimer() {
        startTime = Date()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimerPerSecond), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimerPerSecond() {
        guard let timeLimit = timeLimit, let startTime = startTime else { return }
        let timeElapsed = Int(Date().timeIntervalSince(startTime))
        let timeRemaining = timeLimit - timeElapsed
        if timeRemaining >= 0 {
            output.send(.updateTime(timeLimit: timeLimit, timeRemaining: timeRemaining))
            print(timeLimit, timeRemaining)
        } else {
            guard let currentNumber = curNum else { return }
            curNum = currentNumber + 1
            questionStateHandler()
        }
    }
    
    private func timerStateHandler() {
        guard let currentNumber = curNum else { return }
        if currentNumber < questionList.count {
            curNum = currentNumber + 1
            questionStateHandler()
        } else {
            exitTimer()
            // send result
            output.send(.moveToDailyResult)
        }
    }
    
    private func resetTimer() {
        guard let curNum = curNum else { return }
        startTime = Date()
        timeLimit = questionList[curNum - 1].timeLimit
    }

    private func exitTimer() {
        timer?.invalidate()
        timer = nil
    }
}
