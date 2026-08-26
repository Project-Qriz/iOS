import Foundation
import QRIZNetwork

public struct TermItem: Equatable, Sendable {
    public enum Kind: Equatable, Sendable {
        case term(id: Int)
        case ageConfirmation
    }

    public let kind: Kind
    public let title: String
    public let documentUrl: String?
    public let pdfName: String?
    public var isAgreed: Bool

    public init(
        kind: Kind,
        title: String,
        documentUrl: String? = nil,
        pdfName: String? = nil,
        isAgreed: Bool
    ) {
        self.kind = kind
        self.title = title
        self.documentUrl = documentUrl
        self.pdfName = pdfName
        self.isAgreed = isAgreed
    }

    /// `.term`이면 서버 약관 id, `.ageConfirmation`이면 nil
    public var id: Int? {
        if case .term(let id) = kind { return id }
        return nil
    }
}

public extension TermItem {
    /// `documentUrl`이 없는 약관을 앱에 번들된 로컬 PDF로 폴백 렌더링하기 위한 매핑.
    ///
    /// 서버(`GET /api/terms`)가 특정 약관에 `documentUrl`을 내려주지 않는 경우
    /// `TermsDetailViewModel.loadPDF()`가 이 이름으로 `Bundle.main`에서 PDF를 찾는다.
    /// 실제 번들 리소스: `QRIZ/Resources/PDF/TermsAgreement/{TermsOfService,PrivacyPolicy}.pdf`
    static func bundledPDFName(for type: TermType) -> String {
        switch type {
        case .service: return "TermsOfService"
        case .privacy: return "PrivacyPolicy"
        }
    }

    /// 서버(`GET /api/terms`)는 약관 제목을 내려주지 않으므로(`type`만 제공),
    /// 화면에 표시할 한글 라벨은 클라이언트에서 `type` 기준으로 결정한다.
    static func displayTitle(for type: TermType) -> String {
        switch type {
        case .service: return "서비스 이용약관"
        case .privacy: return "개인정보 처리방침"
        }
    }
}
