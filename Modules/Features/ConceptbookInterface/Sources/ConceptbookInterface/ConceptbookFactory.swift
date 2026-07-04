import UIKit
import QRIZUtils

@MainActor
public protocol ConceptbookFactory {
    func makeConceptPDFViewController(chapter: Chapter, conceptItem: ConceptItem) -> UIViewController
}
