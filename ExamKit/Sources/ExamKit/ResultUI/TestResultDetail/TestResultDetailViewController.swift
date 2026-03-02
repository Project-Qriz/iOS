//
//  TestResultDetailViewController.swift
//  ExamKit
//

import UIKit
import SwiftUI
import Combine

public final class TestResultDetailViewController: UIViewController {

    // MARK: - Properties
    private let viewModel: TestResultDetailViewModel

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
        view.backgroundColor = .white
        let resultDetailView = ResultDetailView(
            resultScoresData: viewModel.resultScoresData,
            resultDetailData: viewModel.resultDetailData
        )
        bind(to: resultDetailView.input)
        embedHostingController(rootView: resultDetailView)
    }

    private func bind(to input: PassthroughSubject<TestResultDetailViewModel.Input, Never>) {
        viewModel.transform(input: input.eraseToAnyPublisher())
    }
}

// MARK: - Layout
extension TestResultDetailViewController {
    private func embedHostingController(rootView: ResultDetailView) {
        let hostingController = UIHostingController(rootView: rootView)
        addChild(hostingController)
        hostingController.didMove(toParent: self)
        view.addSubview(hostingController.view)

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}
