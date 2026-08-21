import Testing
@testable import Account

@Suite("TermItem 테스트")
struct TermItemTests {
    @Test(".term(id:)인 경우 id가 해당 값을 반환한다")
    func termKindReturnsId() {
        let item = TermItem(kind: .term(id: 7), title: "이용약관", isAgreed: false)
        #expect(item.id == 7)
    }

    @Test(".ageConfirmation인 경우 id는 nil이다")
    func ageConfirmationKindHasNoId() {
        let item = TermItem(kind: .ageConfirmation, title: "만 14세 이상", isAgreed: false)
        #expect(item.id == nil)
    }
}
