import Testing
@testable import Onboarding

@MainActor
@Suite("BeginOnboardingViewModel 테스트")
struct BeginOnboardingViewModelTests {

    @Test("didTapButton 호출 시 onNavigate 클로저 실행됨")
    func didTapButton_callsOnNavigate() {
        var navigateCalled = false
        let sut = BeginOnboardingViewModel(onNavigate: { navigateCalled = true })

        sut.didTapButton()

        #expect(navigateCalled)
    }
}
