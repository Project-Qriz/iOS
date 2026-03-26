import Testing
import Combine
@testable import MyPage
import Network

@MainActor
@Suite("MyPageViewModel 테스트", .serialized)
struct MyPageViewModelTests {

    private func makeSUT(
        userName: String = "테스트",
        service: MockMyPageService = .init()
    ) -> MyPageViewModel {
        MyPageViewModel(userName: userName, myPageService: service)
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

        #expect(received.count == 1)
        guard case .setupView(let userName, let version) = received[0] else {
            Issue.record("Expected .setupView, got \(received)")
            return
        }
        #expect(userName == "테스트")
        // MockMyPageService returns versionInfo: Float = 1.0
        // Swift String interpolation of Float(1.0) produces "1.0" (locale-independent)
        #expect(version == "1.0")
    }

    @Test("viewDidLoad → fetchVersion NetworkError 실패 → setupView(fallback) emit")
    func viewDidLoad_fetchVersionNetworkError_emitsSetupViewWithFallback() async throws {
        let service = MockMyPageService()
        service.fetchVersionResult = .failure(NetworkError.serverError)
        let sut = makeSUT(service: service)
        let inputSubject = PassthroughSubject<MyPageViewModel.Input, Never>()
        var received: [MyPageViewModel.Output] = []
        var cancellables = Set<AnyCancellable>()

        sut.transform(input: inputSubject.eraseToAnyPublisher())
            .sink { received.append($0) }
            .store(in: &cancellables)

        inputSubject.send(.viewDidLoad)
        try await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(received.count == 1)
        guard case .setupView(let userName, let version) = received[0] else {
            Issue.record("Expected .setupView, got \(received)")
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

        #expect(received.count == 1)
        guard case .setupView(let userName, let version) = received[0] else {
            Issue.record("Expected .setupView, got \(received)")
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

        #expect(received.count == 1)
        guard case .navigateToSettingsView = received[0] else {
            Issue.record("Expected .navigateToSettingsView, got \(received)")
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

        #expect(received.count == 1)
        guard case .showResetAlert = received[0] else {
            Issue.record("Expected .showResetAlert, got \(received)")
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

        #expect(received.count == 1)
        guard case .showExamSchedule = received[0] else {
            Issue.record("Expected .showExamSchedule, got \(received)")
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

        #expect(received.count == 1)
        guard case .showTermsDetail(let termItem) = received[0] else {
            Issue.record("Expected .showTermsDetail, got \(received)")
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

        #expect(received.count == 1)
        guard case .showTermsDetail(let termItem) = received[0] else {
            Issue.record("Expected .showTermsDetail, got \(received)")
            return
        }
        #expect(termItem.title == "개인정보 처리방침")
        #expect(termItem.pdfName == "PrivacyPolicy")
    }
}
