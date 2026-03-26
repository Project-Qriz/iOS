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
}
