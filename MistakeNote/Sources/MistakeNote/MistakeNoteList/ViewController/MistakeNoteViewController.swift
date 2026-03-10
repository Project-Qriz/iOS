//
//  MistakeNoteViewController.swift
//  MistakeNote
//
//  Created by 김세훈 on 2/23/25.
//

import UIKit
import DesignSystem
import SwiftUI

@MainActor
public protocol MistakeNoteViewControllerDelegate: AnyObject {
    func mistakeNoteViewController(_ viewController: MistakeNoteViewController, didSelectClipWithId clipId: Int)
    func mistakeNoteViewController(_ viewController: MistakeNoteViewController, didRequestExamForTab tab: MistakeNoteTab)
}

@MainActor
public final class MistakeNoteViewController: UIHostingController<MistakeNoteMainView> {

    // MARK: - Properties

    public weak var delegate: MistakeNoteViewControllerDelegate?
    private let viewModel: MistakeNoteListViewModel

    // MARK: - Initialize

    public init(viewModel: MistakeNoteListViewModel) {
        self.viewModel = viewModel
        let mistakeNoteView = MistakeNoteMainView(viewModel: viewModel)
        super.init(rootView: mistakeNoteView)
    }

    @MainActor required dynamic public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCycle

    override public func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationTitle()
        bind()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }

    // MARK: - Private Methods

    private func configureNavigationTitle() {
        setNavigationBarTitle(title: "오답노트", textColor: UIColor.coolNeutral800)
    }

    private func configureNavigationBar() {
        let appearance = UINavigationBar.defaultBackButtonStyle()
        appearance.shadowColor = .clear
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    private func bind() {
        viewModel.onNavigate = { [weak self] output in
            guard let self else { return }
            switch output {
            case .navigateToClipDetail(let clipId):
                self.delegate?.mistakeNoteViewController(self, didSelectClipWithId: clipId)
            case .navigateToExam(let tab):
                self.delegate?.mistakeNoteViewController(self, didRequestExamForTab: tab)
            }
        }
    }
}
