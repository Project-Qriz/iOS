//
//  ProblemDetailViewController.swift
//  QRIZ
//
//  Created by Claude on 12/30/25.
//

import UIKit
import SwiftUI

@MainActor
final class ProblemDetailViewController: UIHostingController<ProblemDetailView> {

    weak var coordinator: MistakeNoteCoordinator?
    private let viewModel: ProblemDetailViewModel

    init(viewModel: ProblemDetailViewModel) {
        self.viewModel = viewModel
        let swiftUIView = ProblemDetailView(viewModel: viewModel)
        super.init(rootView: swiftUIView)
        self.hidesBottomBarWhenPushed = true
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
