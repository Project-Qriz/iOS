import Foundation

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
