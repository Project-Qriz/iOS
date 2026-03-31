import UIKit
import Combine

final class ExamSummaryViewController: UIViewController {

    // MARK: - Properties

    weak var coordinator: (any ExamNavigating)?
    private let rootView: ExamSummaryView
    private let viewModel: ExamSummaryViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(viewModel: ExamSummaryViewModel) {
        self.rootView = ExamSummaryView()
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        self.view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyBlueNavigationAppearance()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        restoreDefaultNavigationAppearance()
    }

    // MARK: - Methods

    private func bind() {
        let input = rootView.beginExamTapPublisher
            .map { ExamSummaryViewModel.Input.didTapBeginExam }
            .eraseToAnyPublisher()

        let output = viewModel.transform(input: input)

        output
            .sink { [weak self] event in
                guard let self else { return }
                switch event {
                case .moveToExam(let examId):
                    coordinator?.showExamTest(examId: examId)
                }
            }
            .store(in: &cancellables)
    }

    private func applyBlueNavigationAppearance() {
        let appearance = UINavigationBar.defaultBackButtonStyle()
        appearance.backgroundColor = .customBlue50
        applyNavigationAppearance(appearance)
    }

    private func restoreDefaultNavigationAppearance() {
        applyNavigationAppearance(UINavigationBar.defaultBackButtonStyle())
    }

    private func applyNavigationAppearance(_ appearance: UINavigationBarAppearance) {
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
}
