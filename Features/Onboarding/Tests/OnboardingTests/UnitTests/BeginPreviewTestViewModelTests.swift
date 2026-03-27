import Testing
@testable import Onboarding

@MainActor
@Suite("BeginPreviewTestViewModel 테스트")
struct BeginPreviewTestViewModelTests {

    @Test("didTapButton 호출 시 onNavigate 클로저 실행됨")
    func didTapButton_callsOnNavigate() {
        var navigateCalled = false
        let sut = BeginPreviewTestViewModel(onNavigate: { navigateCalled = true })

        sut.didTapButton()

        #expect(navigateCalled)
    }
}
