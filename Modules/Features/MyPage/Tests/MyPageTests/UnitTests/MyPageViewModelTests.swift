import Foundation
import Testing
import Combine
@testable import MyPage
import QRIZNetwork

@MainActor
@Suite("MyPageViewModel 테스트", .serialized)
struct MyPageViewModelTests {

    private func makeSUT(
        userName: String = "테스트",
        service: MockMyPageService? = nil
    ) -> MyPageViewModel {
        MyPageViewModel(userName: userName, myPageService: service ?? MockMyPageService())
    }

    // MARK: - viewDidLoad

    @Test("viewDidLoad → fetchVersion 성공 → setupView emit")
    func viewDidLoad_fetchVersionSuccess_emitsSetupView() async throws {
        let sut = makeSUT()
        let inputSubject = PassthroughSubject<MyPageViewModel.Input, Never>()
        var received: [MyPageViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.viewDidLoad)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count): \(received)")
            return
        }
        guard case .setupView(let userName, let version) = first else {
            Issue.record("Expected .setupView, got \(first)")
            return
        }
        #expect(userName == "테스트")
        #expect(version == "1.0")
    }

    @Test("viewDidLoad → fetchVersion NetworkError 실패 → setupView(fallback) emit")
    func viewDidLoad_fetchVersionNetworkError_emitsSetupViewWithFallback() async throws {
        let service = MockMyPageService()
        service.fetchVersionResult = .failure(NetworkError.serverError(httpStatus: 500))
        let sut = makeSUT(service: service)
        let inputSubject = PassthroughSubject<MyPageViewModel.Input, Never>()
        var received: [MyPageViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.viewDidLoad)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count): \(received)")
            return
        }
        guard case .setupView(let userName, let version) = first else {
            Issue.record("Expected .setupView, got \(first)")
            return
        }
        #expect(userName == "테스트")
        #expect(version == "0.0.0")
    }

    @Test("viewDidLoad → fetchVersion 일반 Error 실패 → setupView(fallback) emit")
    func viewDidLoad_fetchVersionGenericError_emitsSetupViewWithFallback() async throws {
        let service = MockMyPageService()
        service.fetchVersionResult = .failure(URLError(.notConnectedToInternet))
        let sut = makeSUT(service: service)
        let inputSubject = PassthroughSubject<MyPageViewModel.Input, Never>()
        var received: [MyPageViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.viewDidLoad)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count): \(received)")
            return
        }
        guard case .setupView(let userName, let version) = first else {
            Issue.record("Expected .setupView, got \(first)")
            return
        }
        #expect(userName == "테스트")
        #expect(version == "0.0.0")
    }

    // MARK: - 동기 탭 이벤트

    @Test("didTapProfile → navigateToSettingsView emit")
    func didTapProfile_emitsNavigateToSettingsView() {
        let sut = makeSUT()
        let inputSubject = PassthroughSubject<MyPageViewModel.Input, Never>()
        var received: [MyPageViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didTapProfile)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count): \(received)")
            return
        }
        guard case .navigateToSettingsView = first else {
            Issue.record("Expected .navigateToSettingsView, got \(first)")
            return
        }
    }

    @Test("didTapResetPlan → showResetAlert emit")
    func didTapResetPlan_emitsShowResetAlert() {
        let sut = makeSUT()
        let inputSubject = PassthroughSubject<MyPageViewModel.Input, Never>()
        var received: [MyPageViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didTapResetPlan)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count): \(received)")
            return
        }
        guard case .showResetAlert = first else {
            Issue.record("Expected .showResetAlert, got \(first)")
            return
        }
    }

    @Test("didTapRegisterExam → showExamSchedule emit")
    func didTapRegisterExam_emitsShowExamSchedule() {
        let sut = makeSUT()
        let inputSubject = PassthroughSubject<MyPageViewModel.Input, Never>()
        var received: [MyPageViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didTapRegisterExam)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count): \(received)")
            return
        }
        guard case .showExamSchedule = first else {
            Issue.record("Expected .showExamSchedule, got \(first)")
            return
        }
    }

    @Test("didTapTermsOfService → showTermsDetail(서비스 이용약관) emit")
    func didTapTermsOfService_emitsShowTermsDetailWithTermsOfService() {
        let sut = makeSUT()
        let inputSubject = PassthroughSubject<MyPageViewModel.Input, Never>()
        var received: [MyPageViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didTapTermsOfService)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count): \(received)")
            return
        }
        guard case .showTermsDetail(let termItem) = first else {
            Issue.record("Expected .showTermsDetail, got \(first)")
            return
        }
        #expect(termItem.title == "서비스 이용약관")
        #expect(termItem.pdfName == "TermsOfService")
    }

    @Test("didTapPrivacyPolicy → showTermsDetail(개인정보 처리방침) emit")
    func didTapPrivacyPolicy_emitsShowTermsDetailWithPrivacyPolicy() {
        let sut = makeSUT()
        let inputSubject = PassthroughSubject<MyPageViewModel.Input, Never>()
        var received: [MyPageViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didTapPrivacyPolicy)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count): \(received)")
            return
        }
        guard case .showTermsDetail(let termItem) = first else {
            Issue.record("Expected .showTermsDetail, got \(first)")
            return
        }
        #expect(termItem.title == "개인정보 처리방침")
        #expect(termItem.pdfName == "PrivacyPolicy")
    }

    // MARK: - didConfirmResetPlan

    @Test("didConfirmResetPlan → resetPlan 성공 → resetSucceeded emit")
    func didConfirmResetPlan_resetPlanSuccess_emitsResetSucceeded() async throws {
        let sut = makeSUT()
        let inputSubject = PassthroughSubject<MyPageViewModel.Input, Never>()
        var received: [MyPageViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didConfirmResetPlan)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count): \(received)")
            return
        }
        guard case .resetSucceeded(let message) = first else {
            Issue.record("Expected .resetSucceeded, got \(first)")
            return
        }
        #expect(message == "초기화 완료!")
    }

    @Test("didConfirmResetPlan → resetPlan NetworkError 실패 → showErrorAlert emit")
    func didConfirmResetPlan_resetPlanNetworkError_emitsShowErrorAlert() async throws {
        let service = MockMyPageService()
        service.resetPlanResult = .failure(NetworkError.serverError(httpStatus: 500))
        let sut = makeSUT(service: service)
        let inputSubject = PassthroughSubject<MyPageViewModel.Input, Never>()
        var received: [MyPageViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didConfirmResetPlan)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count): \(received)")
            return
        }
        guard case .showErrorAlert(let title, let description) = first else {
            Issue.record("Expected .showErrorAlert, got \(first)")
            return
        }
        #expect(title == "초기화할 수 없습니다.")
        #expect(description == "서버 에러가 발생했습니다. 잠시 후 다시 시도해 주세요.")
    }

    @Test("didConfirmResetPlan → resetPlan 일반 Error 실패 → showErrorAlert emit")
    func didConfirmResetPlan_resetPlanGenericError_emitsShowErrorAlert() async throws {
        let service = MockMyPageService()
        service.resetPlanResult = .failure(URLError(.notConnectedToInternet))
        let sut = makeSUT(service: service)
        let inputSubject = PassthroughSubject<MyPageViewModel.Input, Never>()
        var received: [MyPageViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.didConfirmResetPlan)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        guard received.count == 1, let first = received.first else {
            Issue.record("Expected 1 output, got \(received.count): \(received)")
            return
        }
        guard case .showErrorAlert(let title, let description) = first else {
            Issue.record("Expected .showErrorAlert, got \(first)")
            return
        }
        #expect(title == "초기화할 수 없습니다.")
        #expect(description == "잠시 후 다시 시도해주세요.")
    }
}
