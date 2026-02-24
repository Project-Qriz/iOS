//
//  TestResultDetailViewController.swift
//  ExamKit
//

import UIKit
import Combine

public final class TestResultDetailViewController: UIViewController {

    // MARK: - Properties
    private var resultDetailHostingController: ResultDetailHostingController!

    private let viewModel: TestResultDetailViewModel
    private let input: PassthroughSubject<TestResultDetailViewModel.Input, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Initializers
    public init(viewModel: TestResultDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        addViews()
        bind()
    }

    private func bind() {
        let mergedInput = input.merge(with: resultDetailHostingController.rootView.input)
        viewModel.transform(input: mergedInput.eraseToAnyPublisher())
    }

    private func loadDetailView() -> UIView {
        resultDetailHostingController = ResultDetailHostingController(
            rootView: ResultDetailView(
                resultScoreData: self.viewModel.resultScoresData,
                resultDetailData: self.viewModel.resultDetailData
            )
        )
        self.addChild(resultDetailHostingController)
        resultDetailHostingController.didMove(toParent: self)

        let detailView = resultDetailHostingController.view ?? UIView(frame: .zero)
        return detailView
    }
}

// MARK: - Auto Layout
extension TestResultDetailViewController {
    private func addViews() {
        let resultDetailView = loadDetailView()
        self.view.addSubview(resultDetailView)

        resultDetailView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            resultDetailView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            resultDetailView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            resultDetailView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            resultDetailView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }
}
