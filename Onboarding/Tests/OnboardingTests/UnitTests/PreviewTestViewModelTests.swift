import Testing
import Foundation
import Combine
import Network
@testable import Onboarding

@MainActor
@Suite("PreviewTestViewModel 테스트", .serialized)
struct PreviewTestViewModelTests {

    private func makeSUT(service: MockOnboardingService = .init()) -> PreviewTestViewModel {
        PreviewTestViewModel(onboardingService: service)
    }

    private func makeInput() -> (
        subject: PassthroughSubject<PreviewTestViewModel.Input, Never>,
        publisher: AnyPublisher<PreviewTestViewModel.Input, Never>
    ) {
        let subject = PassthroughSubject<PreviewTestViewModel.Input, Never>()
        return (subject, subject.eraseToAnyPublisher())
    }

    // MARK: - viewDidLoad 성공

    @Test("viewDidLoad: getPreviewTestList 성공 → updateTotalNum, updateQuestion, updateButtonStates 출력")
    func viewDidLoad_onSuccess_sendsInitialOutputs() async {
        let sut = makeSUT()
        let (subject, inputPublisher) = makeInput()
        let outputPublisher = sut.transform(input: inputPublisher)

        let outputs = await collectOutputs(from: outputPublisher) {
            subject.send(.viewDidLoad)
        }

        let hasUpdateTotalNum = outputs.contains { if case .updateTotalNum = $0 { return true }; return false }
        let hasUpdateQuestion = outputs.contains { if case .updateQuestion = $0 { return true }; return false }
        let hasUpdateButtonStates = outputs.contains { if case .updateButtonStates = $0 { return true }; return false }

        #expect(hasUpdateTotalNum)
        #expect(hasUpdateQuestion)
        #expect(hasUpdateButtonStates)
    }

    // MARK: - viewDidLoad 실패

    @Test("viewDidLoad: getPreviewTestList 실패 → showError 출력")
    func viewDidLoad_onFailure_sendsShowError() async {
        let service = MockOnboardingService()
        service.getPreviewTestListResult = .failure(URLError(.badServerResponse))
        let sut = makeSUT(service: service)
        let (subject, inputPublisher) = makeInput()
        let outputPublisher = sut.transform(input: inputPublisher)

        let outputs = await collectOutputs(from: outputPublisher) {
            subject.send(.viewDidLoad)
        }

        let hasShowError = outputs.contains { if case .showError = $0 { return true }; return false }
        #expect(hasShowError)
    }

    // MARK: - optionTapped

    @Test("optionTapped: 선택 → updateOptionState(isSelected: true)")
    func optionTapped_sendsOptionSelected() async {
        let sut = makeSUT()
        let (subject, inputPublisher) = makeInput()
        let outputPublisher = sut.transform(input: inputPublisher)

        // 먼저 문제 로드
        _ = await collectOutputs(from: outputPublisher) { subject.send(.viewDidLoad) }

        let outputs = await collectOutputs(from: outputPublisher) {
            subject.send(.optionTapped(1))
        }

        let selectedTrue = outputs.contains {
            if case .updateOptionState(let idx, let isSelected) = $0 {
                return idx == 1 && isSelected == true
            }
            return false
        }
        #expect(selectedTrue)
    }

    @Test("optionTapped: 같은 옵션 재탭 → updateOptionState(isSelected: false)")
    func optionTapped_sameTwice_sendsOptionDeselected() async {
        let sut = makeSUT()
        let (subject, inputPublisher) = makeInput()
        let outputPublisher = sut.transform(input: inputPublisher)

        _ = await collectOutputs(from: outputPublisher) { subject.send(.viewDidLoad) }
        _ = await collectOutputs(from: outputPublisher) { subject.send(.optionTapped(1)) }

        let outputs = await collectOutputs(from: outputPublisher) {
            subject.send(.optionTapped(1))
        }

        let deselected = outputs.contains {
            if case .updateOptionState(let idx, let isSelected) = $0 {
                return idx == 1 && isSelected == false
            }
            return false
        }
        #expect(deselected)
    }

    @Test("첫 문제에서 optionTapped: updateButtonStates(nextHidden: false) 출력")
    func optionTapped_onFirstQuestion_updatesButtonStates() async {
        let sut = makeSUT()
        let (subject, inputPublisher) = makeInput()
        let outputPublisher = sut.transform(input: inputPublisher)

        _ = await collectOutputs(from: outputPublisher) { subject.send(.viewDidLoad) }

        let outputs = await collectOutputs(from: outputPublisher) {
            subject.send(.optionTapped(1))
        }

        let buttonStateUpdated = outputs.contains {
            if case .updateButtonStates(_, let nextHidden, _) = $0 {
                return nextHidden == false
            }
            return false
        }
        #expect(buttonStateUpdated)
    }

    // MARK: - 페이지 이동

    @Test("nextTapped: updateQuestion 출력")
    func nextTapped_sendsUpdateQuestion() async {
        let sut = makeSUT()
        let (subject, inputPublisher) = makeInput()
        let outputPublisher = sut.transform(input: inputPublisher)

        _ = await collectOutputs(from: outputPublisher) { subject.send(.viewDidLoad) }
        _ = await collectOutputs(from: outputPublisher) { subject.send(.optionTapped(1)) } // 첫 문제 선택 필요

        let outputs = await collectOutputs(from: outputPublisher) {
            subject.send(.nextTapped)
        }

        let hasUpdateQuestion = outputs.contains { if case .updateQuestion = $0 { return true }; return false }
        #expect(hasUpdateQuestion)
    }

    @Test("prevTapped: updateQuestion 출력")
    func prevTapped_sendsUpdateQuestion() async {
        let sut = makeSUT()
        let (subject, inputPublisher) = makeInput()
        let outputPublisher = sut.transform(input: inputPublisher)

        // 2번째 문제로 이동 후 prevTapped
        _ = await collectOutputs(from: outputPublisher) { subject.send(.viewDidLoad) }
        _ = await collectOutputs(from: outputPublisher) { subject.send(.optionTapped(1)) }
        _ = await collectOutputs(from: outputPublisher) { subject.send(.nextTapped) }

        let outputs = await collectOutputs(from: outputPublisher) {
            subject.send(.prevTapped)
        }

        let hasUpdateQuestion = outputs.contains { if case .updateQuestion = $0 { return true }; return false }
        #expect(hasUpdateQuestion)
    }

    @Test("nextTapped: 마지막 문제에서 showSubmitAlert 출력")
    func nextTapped_onLastQuestion_sendsShowSubmitAlert() async {
        let service = MockOnboardingService()
        service.getPreviewTestListResult = .success(.stub(questionCount: 1))
        let sut = makeSUT(service: service)
        let (subject, inputPublisher) = makeInput()
        let outputPublisher = sut.transform(input: inputPublisher)

        _ = await collectOutputs(from: outputPublisher) { subject.send(.viewDidLoad) }

        let outputs = await collectOutputs(from: outputPublisher) {
            subject.send(.nextTapped)
        }

        let hasSubmitAlert = outputs.contains { if case .showSubmitAlert = $0 { return true }; return false }
        #expect(hasSubmitAlert)
    }

    // MARK: - escapeTapped

    @Test("escapeTapped: navigateToHome 출력")
    func escapeTapped_sendsNavigateToHome() async {
        let sut = makeSUT()
        let (subject, inputPublisher) = makeInput()
        let outputPublisher = sut.transform(input: inputPublisher)

        _ = await collectOutputs(from: outputPublisher) { subject.send(.viewDidLoad) }

        let outputs = await collectOutputs(from: outputPublisher) {
            subject.send(.escapeTapped)
        }

        let hasNavigateToHome = outputs.contains { if case .navigateToHome = $0 { return true }; return false }
        #expect(hasNavigateToHome)
    }

    // MARK: - confirmSubmit

    @Test("confirmSubmit: submitPreview 성공 → navigateToResult 출력")
    func confirmSubmit_onSuccess_sendsNavigateToResult() async {
        let sut = makeSUT()
        let (subject, inputPublisher) = makeInput()
        let outputPublisher = sut.transform(input: inputPublisher)

        _ = await collectOutputs(from: outputPublisher) { subject.send(.viewDidLoad) }

        let outputs = await collectOutputs(from: outputPublisher) {
            subject.send(.confirmSubmit)
        }

        let hasNavigateToResult = outputs.contains { if case .navigateToResult = $0 { return true }; return false }
        #expect(hasNavigateToResult)
    }

    @Test("confirmSubmit: submitPreview 실패 → showSubmitRetryAlert 출력")
    func confirmSubmit_onFailure_sendsShowSubmitRetryAlert() async {
        let service = MockOnboardingService()
        service.submitPreviewResult = .failure(URLError(.badServerResponse))
        let sut = makeSUT(service: service)
        let (subject, inputPublisher) = makeInput()
        let outputPublisher = sut.transform(input: inputPublisher)

        _ = await collectOutputs(from: outputPublisher) { subject.send(.viewDidLoad) }

        let outputs = await collectOutputs(from: outputPublisher) {
            subject.send(.confirmSubmit)
        }

        let hasRetryAlert = outputs.contains { if case .showSubmitRetryAlert = $0 { return true }; return false }
        #expect(hasRetryAlert)
    }

    @Test("confirmSubmit 동시 중복 호출: 두 번째 submit 무시")
    func confirmSubmit_concurrent_secondCallIsIgnored() async {
        let sut = makeSUT()
        let (subject, inputPublisher) = makeInput()
        let outputPublisher = sut.transform(input: inputPublisher)

        _ = await collectOutputs(from: outputPublisher) { subject.send(.viewDidLoad) }

        var navigateToResultCount = 0
        var cancellables = Set<AnyCancellable>()
        outputPublisher.sink {
            if case .navigateToResult = $0 { navigateToResultCount += 1 }
        }.store(in: &cancellables)

        subject.send(.confirmSubmit)
        subject.send(.confirmSubmit) // isSubmitting = true 상태에서 두 번째 — 무시됨

        try? await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(navigateToResultCount == 1)
    }
}
