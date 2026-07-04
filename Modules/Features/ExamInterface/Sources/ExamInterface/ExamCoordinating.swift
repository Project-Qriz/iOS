import UIKit
import QRIZUtils
import QRIZNetwork

@MainActor
public protocol ExamCoordinator: Coordinator {
    var delegate: ExamCoordinatorDelegate? { get set }
}

@MainActor
public protocol ExamCoordinatorDelegate: AnyObject {
    func didQuitExam(_ coordinator: any ExamCoordinator)
    func moveFromExamToConcept(_ coordinator: any ExamCoordinator)
    func conceptPDFViewController(chapter: Chapter, conceptItem: ConceptItem) -> UIViewController
}

@MainActor
public protocol ExamCoordinatorFactory {
    func makeExamCoordinator(
        navigationController: UINavigationController,
        examService: any ExamService,
        adService: any AdService
    ) -> any ExamCoordinator
}
