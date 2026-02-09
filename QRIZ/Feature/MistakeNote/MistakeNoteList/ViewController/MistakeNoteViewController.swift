//
//  MistakeNoteViewController.swift
//  QRIZ
//
//  Created by 김세훈 on 2/23/25.
//

import UIKit
import SwiftUI
import Combine

@MainActor
protocol MistakeNoteViewControllerDelegate: AnyObject {
    func mistakeNoteViewController(_ viewController: MistakeNoteViewController, didSelectClipWithId clipId: Int)
    func mistakeNoteViewController(_ viewController: MistakeNoteViewController, didRequestExamForTab tab: MistakeNoteTab)
}

@MainActor
final class MistakeNoteViewController: UIHostingController<MistakeNoteMainView> {

    // MARK: - Properties

    weak var delegate: MistakeNoteViewControllerDelegate?
    private let viewModel: MistakeNoteListViewModel
    private let input = PassthroughSubject<MistakeNoteListViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialize

    init(viewModel: MistakeNoteListViewModel = MistakeNoteListViewModel()) {
        self.viewModel = viewModel
        let mistakeNoteView = MistakeNoteMainView(viewModel: viewModel)
        super.init(rootView: mistakeNoteView)
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationTitle()
        bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }

    // MARK: - Private Methods

    private func configureNavigationTitle() {
        setNavigationBarTitle(title: "오답노트")
    }

    private func configureNavigationBar() {
        let appearance = UINavigationBar.defaultBackButtonStyle()
        appearance.shadowColor = .clear
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    private func bind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())

        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .navigateToClipDetail(let clipId):
                    self.delegate?.mistakeNoteViewController(self, didSelectClipWithId: clipId)
                case .navigateToExam(let tab):
                    self.delegate?.mistakeNoteViewController(self, didRequestExamForTab: tab)
                }
            }
            .store(in: &cancellables)
    }
}
