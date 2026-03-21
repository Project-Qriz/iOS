import Testing
import QRIZUtils
import Network
@testable import Onboarding

@MainActor
@Suite("GreetingViewModel 테스트", .serialized)
struct GreetingViewModelTests {

    private func resetUserInfo(name: String = "") {
        UserInfoManager.shared.update(
            name: name,
            userId: "",
            email: "",
            previewTestStatus: .notStarted,
            provider: nil
        )
    }

    private func makeSUT(
        service: MockUserInfoService = .init(),
        onNavigate: @escaping () -> Void = {}
    ) -> GreetingViewModel {
        GreetingViewModel(userInfoService: service, onNavigate: onNavigate)
    }

    // MARK: - nickname 즉시 세팅

    @Test("onAppear: UserInfoManager.shared.name을 nickname으로 즉시 세팅")
    func onAppear_setsNicknameFromUserInfoManager() {
        resetUserInfo(name: "홍길동")
        let sut = makeSUT()

        sut.onAppear()

        #expect(sut.nickname == "홍길동")
    }

    // MARK: - fetchUserInfo 성공 시 nickname 업데이트

    @Test("onAppear: fetchUserInfo 성공 시 nickname 업데이트")
    func onAppear_onFetchSuccess_updatesNickname() async {
        resetUserInfo(name: "초기이름")
        let service = MockUserInfoService()
        service.getUserInfoResult = .success(.stub(name: "서버이름"))
        let sut = makeSUT(service: service)

        sut.onAppear()
        try? await Task.sleep(nanoseconds: asyncSleepNanoseconds)

        #expect(sut.nickname == "서버이름")
    }

    // MARK: - 타이머 (실제 2.5초 대기)

    @Test("onAppear: 2.5초 후 onNavigate 호출")
    func onAppear_after2_5Seconds_callsOnNavigate() {
        resetUserInfo()
        var navigateCalled = false
        let sut = makeSUT(onNavigate: { navigateCalled = true })

        sut.onAppear()

        // Timer는 RunLoop 기반 — Task.sleep 대신 RunLoop.main.run으로 드레인
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 2.6))

        #expect(navigateCalled)
    }
}
