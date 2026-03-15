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
public final class MistakeNoteViewController: UIHostingController<MistakeNoteMainView> {

    // MARK: - Properties

    private let viewModel: MistakeNoteListViewModel

    // MARK: - Initialization

    public init(viewModel: MistakeNoteListViewModel) {
        self.viewModel = viewModel
        let mistakeNoteView = MistakeNoteMainView(viewModel: viewModel)
        super.init(rootView: mistakeNoteView)
    }

    @MainActor required dynamic public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override public func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationTitle()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }

    // MARK: - Methods

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

}
