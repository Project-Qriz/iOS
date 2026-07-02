//
//  ProblemDetailViewController.swift
//  ExamKit
//
//  Created by Claude on 12/30/25.
//

import UIKit
import SwiftUI
import QRIZUtils

@MainActor
public protocol ProblemDetailCoordinating: AnyObject {
    func navigateToConceptTab()
    func navigateToConcept(chapter: Chapter, conceptItem: ConceptItem)
}

@MainActor
public final class ProblemDetailViewController: UIHostingController<ProblemDetailView> {

    // MARK: - Properties

    public weak var coordinator: ProblemDetailCoordinating?
    private let viewModel: ProblemDetailViewModel

    // MARK: - Initialization

    public init(viewModel: ProblemDetailViewModel) {
        self.viewModel = viewModel
        super.init(rootView: ProblemDetailView(viewModel: viewModel))
        self.hidesBottomBarWhenPushed = true
    }

    @MainActor required dynamic public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override public func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationTitle()
        bind()
        viewModel.viewDidLoad()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }

    // MARK: - Methods

    private func configureNavigationTitle() {
        navigationItem.title = "오답노트"
    }

    private func configureNavigationBar() {
        let appearance = UINavigationBar.defaultBackButtonStyle()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    private func bind() {
        viewModel.onNavigate = { [weak self] output in
            guard let self else { return }
            switch output {
            case .navigateToConceptTab:
                self.coordinator?.navigateToConceptTab()
            case .navigateToConceptDetail(let chapter, let conceptItem):
                self.coordinator?.navigateToConcept(chapter: chapter, conceptItem: conceptItem)
            }
        }
    }
}
