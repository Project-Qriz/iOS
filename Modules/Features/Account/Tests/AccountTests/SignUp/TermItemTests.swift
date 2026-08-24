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

    // MARK: - bundledPDFName(forTitle:)

    @Test("이용약관 제목 → 번들 PDF TermsOfService", arguments: [
        "이용약관", "서비스 이용약관", "QRIZ 서비스 이용약관(필수)"
    ])
    func termsOfServiceTitleMapsToBundledPDF(title: String) {
        #expect(TermItem.bundledPDFName(forTitle: title) == "TermsOfService")
    }

    @Test("개인정보 관련 제목 → 번들 PDF PrivacyPolicy", arguments: [
        "개인정보", "개인정보 처리방침", "개인정보 수집·이용 동의(필수)"
    ])
    func privacyPolicyTitleMapsToBundledPDF(title: String) {
        #expect(TermItem.bundledPDFName(forTitle: title) == "PrivacyPolicy")
    }

    @Test("매칭되는 번들 PDF가 없으면 nil")
    func unknownTitleMapsToNil() {
        #expect(TermItem.bundledPDFName(forTitle: "마케팅 정보 수신 동의") == nil)
        #expect(TermItem.bundledPDFName(forTitle: "") == nil)
    }
}
