//
//  MistakeNoteViewController.swift
//  QRIZ
//
//  Created by 김세훈 on 2/23/25.
//

import UIKit
import SwiftUI

@MainActor
final class MistakeNoteViewController: UIHostingController<MistakeNoteMainView> {

    // MARK: - Initialize

    init() {
        let mistakeNoteView = MistakeNoteMainView()
        super.init(rootView: mistakeNoteView)
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationTitle()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }

    // MARK: - Function

    private func configureNavigationTitle() {
        setNavigationBarTitle(title: "오답노트")
    }

    private func configureNavigationBar() {
        let appearance = UINavigationBar.defaultBackButtonStyle()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
}
