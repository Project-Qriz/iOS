//
//  PreviewTestViewModel.swift
//  QRIZ
//
//  Created by ch on 12/18/24.
//

import Foundation
import Combine

final class PreviewTestViewModel {
    
    // MARK: - Input & Output
    enum Input {
        case viewDidLoad
        case prevButtonClicked(selectedOption: Int?)
        case nextButtonClicked(selectedOption: Int?)
        case escapeButtonClicked
        case alertSubmitButtonClicked
        case alertCancelButtonClicked
    }
    
    enum Output {
        case fetchFailed
        case updateQuestion(question: PreviewTestListQuestion, curNum: Int, selectedOption: Int?)
        case updateLastQuestionNum(num: Int)
        case updateTime(timeLimit: Int, timeRemaining: Int)
        case moveToPreviewResult
        case moveToHome
        case popUpAlert
        case submitSuccess
        case submitFail
        case cancelAlert
    }
    
    // MARK: - Properties
    private var questionList: [PreviewTestListQuestion] = [] // 문제 리스트
    private var submitList: [TestSubmitData] = [] // 제출을 위한 TestSubmitData 리스트
    private var selectedList: [Int?] = [] // UI를 위한 선택된 옵션 리스트
    private var currentNumber: Int? = nil
    private var totalTimeLimit: Int? = nil
    private var timer: Timer? = nil
    private var startTime: Date? = nil
    
    private let output: PassthroughSubject<Output, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    
    private let onboardingService: OnboardingService
    
    // MARK: - Initializer
    init(onboardingService: OnboardingService) {
        self.onboardingService = onboardingService
    }
    
    // MARK: - Deinitializer
    deinit {
        exitTimer()
        print("DEINIT: PreviewTestViewModel")
    }
    
    // MARK: - Methods
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .viewDidLoad:
                getPreviewTestList()
            case .prevButtonClicked(let selectedOption):
                updateAnswer(selectedOption: selectedOption)
                pageButtonsActionHandler(isNextButton: false)
            case .nextButtonClicked(let selectedOption):
                updateAnswer(selectedOption: selectedOption)
                pageButtonsActionHandler(isNextButton: true)
            case .escapeButtonClicked:
                exitTimer()
                // coordinator role
                output.send(.moveToHome)
            case .alertSubmitButtonClicked:
                submitHandler()
            case .alertCancelButtonClicked:
                output.send(.cancelAlert)
            }
        }
        .store(in: &subscriptions)
        return output.eraseToAnyPublisher()
    }
    
    private func submitHandler() {
        Task {
            do {
                let _ = try await onboardingService.submitPreview(testSubmitDataList: submitList)
                exitTimer()
                output.send(.submitSuccess)
                output.send(.moveToPreviewResult)
            } catch {
                output.send(.submitFail)
            }
        }
    }
    
    private func updateAnswer(selectedOption: Int?) {
        if let currentNumber {
            selectedList[currentNumber - 1] = selectedOption
            
            if let selectedOpt = selectedOption {
                submitList[currentNumber - 1].optionId = questionList[currentNumber - 1].options[selectedOpt - 1].id
            } else {
                submitList[currentNumber - 1].optionId = nil
            }
        }
    }
    
    private func pageButtonsActionHandler(isNextButton: Bool) {
        guard let curNum = currentNumber else { return }
        if isNextButton && curNum >= questionList.count {
            output.send(.popUpAlert)
        } else {
            let pageDiff = isNextButton ? 1 : -1
            currentNumber = curNum + pageDiff
            output.send(.updateQuestion(question: questionList[currentNumber! - 1], curNum: currentNumber!, selectedOption: selectedList[currentNumber! - 1]))
        }
    }
    
    private func getPreviewTestList() {
        Task {
            do {
                let response = try await onboardingService.getPreviewTestList()
                let questions = response.data.questions
                if !questions.isEmpty {
                    currentNumber = 1
                    totalTimeLimit = response.data.totalTimeLimit
                    sendTimer()
                    questionList = response.data.questions
                    initSubmitList(response)
                    initSelectedList(response.data.questions.count)
                    output.send(.updateLastQuestionNum(num: questionList.count))
                    output.send(.updateQuestion(question: questionList[0], curNum: currentNumber!, selectedOption: selectedList[0]))
                }
            } catch {
                output.send(.fetchFailed)
            }
        }
    }
    
    private func initSubmitList(_ response: PreviewTestListResponse) {
        response.data.questions.enumerated().forEach { [weak self] idx, question in
            guard let self = self else { return }
            self.submitList.append(TestSubmitData(question: SubmitQuestionData(questionId: question.questionId, category: question.category), questionNum: idx + 1, optionId: -1))
        }
    }
    
    private func initSelectedList(_ len: Int) {
        selectedList = Array(repeating: nil, count: len)
    }
}

// MARK: - Methods For Timer
extension PreviewTestViewModel {
    private func sendTimer() {
        guard let totalTimeLimit = totalTimeLimit else { return }
        output.send(.updateTime(timeLimit: totalTimeLimit, timeRemaining: totalTimeLimit))
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.startTimer()
        }
    }
    
    private func startTimer() {
        startTime = Date()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    @objc func updateTimer() {
        guard let totalTimeLimit = totalTimeLimit, let startTime = startTime else { return }
        let timeElapsed = Int(Date().timeIntervalSince(startTime))
        let timeRemaining = totalTimeLimit - timeElapsed
        if timeRemaining >= 0 {
            output.send(.updateTime(timeLimit: totalTimeLimit, timeRemaining: timeRemaining))
        } else {
            // send result
            output.send(.moveToPreviewResult)
            exitTimer()
        }
    }
    
    private func exitTimer() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.timer?.invalidate()
            self.timer = nil
        }
    }
}
