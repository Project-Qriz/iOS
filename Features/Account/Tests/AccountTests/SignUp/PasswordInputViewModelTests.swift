//
//  PasswordInputViewModelTests.swift
//  AccountTests
//

import Testing
import Combine
@testable import Account

@MainActor
@Suite("PasswordInputViewModel 테스트", .serialized)
struct PasswordInputViewModelTests {

    private func makeSUT() -> PasswordInputViewModel {
        let flowVM = SignUpFlowViewModel(signUpService: MockSignUpService())
        return PasswordInputViewModel(signUpFlowViewModel: flowVM)
    }

    // MARK: - 비밀번호 유효성 검사

    @Test("유효한 비밀번호 입력 시 characterRequirement, lengthRequirement, passwordValid 모두 true")
    func validPasswordSatisfiesAllRequirements() {
        let sut = makeSUT()
        let outputs = collect(sut.output) { sut.send(.passwordTextChanged("Valid@1234")) }

        #expect(outputs.contains(.characterRequirementChanged(true)))
        #expect(outputs.contains(.lengthRequirementChanged(true)))
        #expect(outputs.contains(.passwordValidChanged(true)))
    }

    @Test("특수문자 없는 비밀번호 → characterRequirement false")
    func missingSpecialCharacterFailsCharacterRequirement() {
        let sut = makeSUT()
        let outputs = collect(sut.output) { sut.send(.passwordTextChanged("Valid1234")) }

        #expect(outputs.contains(.characterRequirementChanged(false)))
    }

    @Test("7자 비밀번호 → lengthRequirement false")
    func tooShortPasswordFailsLengthRequirement() {
        let sut = makeSUT()
        let outputs = collect(sut.output) { sut.send(.passwordTextChanged("Vl@123")) }

        #expect(outputs.contains(.lengthRequirementChanged(false)))
    }

    @Test("유효한 비밀번호 입력 전 버튼 비활성화")
    func buttonDisabledBeforeValidPassword() {
        let sut = makeSUT()
        let outputs = collect(sut.output) { sut.send(.passwordTextChanged("short")) }

        #expect(outputs.contains(.updateButtonState(false)))
    }

    // MARK: - 비밀번호 확인 유효성 검사

    @Test("일치하는 확인 비밀번호 입력 → confirmValid true, 버튼 활성화")
    func matchingConfirmPasswordEnablesButton() {
        let sut = makeSUT()
        sut.send(.passwordTextChanged("Valid@1234"))
        let outputs = collect(sut.output) { sut.send(.confirmPasswordTextChanged("Valid@1234")) }

        #expect(outputs.contains(.confirmValidChanged(true)))
        #expect(outputs.contains(.updateButtonState(true)))
    }

    @Test("불일치하는 확인 비밀번호 → confirmValid false, 버튼 비활성화")
    func mismatchConfirmPasswordDisablesButton() {
        let sut = makeSUT()
        sut.send(.passwordTextChanged("Valid@1234"))
        let outputs = collect(sut.output) { sut.send(.confirmPasswordTextChanged("Wrong@1234")) }

        #expect(outputs.contains(.confirmValidChanged(false)))
        #expect(outputs.contains(.updateButtonState(false)))
    }

    @Test("비밀번호가 유효하지 않으면 확인 비밀번호가 일치해도 버튼 비활성화")
    func invalidPasswordDisablesButtonEvenIfConfirmMatches() {
        let sut = makeSUT()
        sut.send(.passwordTextChanged("weak"))
        let outputs = collect(sut.output) { sut.send(.confirmPasswordTextChanged("weak")) }

        #expect(outputs.contains(.updateButtonState(false)))
    }

    @Test("confirmPassword 미수정 상태에서 passwordValid 변경 시 confirmValidChanged 미발송")
    func confirmValidNotSentBeforeConfirmEdited() {
        let sut = makeSUT()
        let outputs = collect(sut.output) { sut.send(.passwordTextChanged("Valid@1234")) }

        let hasConfirmValid = outputs.contains { output in
            if case .confirmValidChanged = output { return true }
            return false
        }
        #expect(!hasConfirmValid)
    }
}
