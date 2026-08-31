import Testing
@testable import Account
import QRIZNetwork

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

    // MARK: - bundledPDFName(for:)

    @Test("SERVICE → 번들 PDF TermsOfService")
    func serviceTypeMapsToBundledPDF() {
        #expect(TermItem.bundledPDFName(for: .service) == "TermsOfService")
    }

    @Test("PRIVACY → 번들 PDF PrivacyPolicy")
    func privacyTypeMapsToBundledPDF() {
        #expect(TermItem.bundledPDFName(for: .privacy) == "PrivacyPolicy")
    }

    // MARK: - displayTitle(for:)

    @Test("SERVICE → \"서비스 이용약관\"")
    func serviceTypeMapsToDisplayTitle() {
        #expect(TermItem.displayTitle(for: .service) == "서비스 이용약관")
    }

    @Test("PRIVACY → \"개인정보 처리방침\"")
    func privacyTypeMapsToDisplayTitle() {
        #expect(TermItem.displayTitle(for: .privacy) == "개인정보 처리방침")
    }
}
