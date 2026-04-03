//
//  NameInputViewModelTests.swift
//  AccountTests
//

import Testing
import Combine
@testable import Account

@MainActor
@Suite("NameInputViewModel 테스트", .serialized)
struct NameInputViewModelTests {

    private func makeSUT() -> NameInputViewModel {
        let flowVM = SignUpFlowViewModel(signUpService: MockSignUpService())
        return NameInputViewModel(signUpFlowViewModel: flowVM)
    }

    // MARK: - 이름 유효성 검사

    @Test("유효한 이름 → isNameValid true")
    func validNameEmitsTrue() {
        let sut = makeSUT()
        let outputs = collect(sut.output) { sut.send(.nameTextChanged("홍길동")) }

        #expect(outputs.contains(.isNameValid(true)))
    }

    @Test("빈 이름 → isNameValid false")
    func emptyNameEmitsFalse() {
        let sut = makeSUT()
        let outputs = collect(sut.output) { sut.send(.nameTextChanged("")) }

        #expect(outputs.contains(.isNameValid(false)))
    }

    // MARK: - 버튼 탭

    @Test("buttonTapped → navigateToIDInputView")
    func buttonTappedNavigatesToIDInput() {
        let sut = makeSUT()
        sut.send(.nameTextChanged("홍길동"))
        let outputs = collect(sut.output) { sut.send(.buttonTapped) }

        #expect(outputs.contains(.navigateToIDInputView))
    }
}
