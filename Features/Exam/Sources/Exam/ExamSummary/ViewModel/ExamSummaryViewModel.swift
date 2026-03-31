import Foundation
import Combine

@MainActor
final class ExamSummaryViewModel {

    // MARK: - Properties

    private let examId: Int
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(examId: Int) {
        self.examId = examId
    }

    // MARK: - Methods

    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink { [weak self] event in
                guard let self else { return }
                switch event {
                case .didTapBeginExam:
                    outputSubject.send(.moveToExam(examId: examId))
                }
            }
            .store(in: &cancellables)

        return outputSubject.eraseToAnyPublisher()
    }
}

// MARK: - Input & Output

extension ExamSummaryViewModel {
    enum Input {
        case didTapBeginExam
    }

    enum Output {
        case moveToExam(examId: Int)
    }
}
