//
//  ChapterDetailViewController.swift
//  QRIZ
//
//  Created by 김세훈 on 4/18/25.
//

import UIKit
import Combine

final class ChapterDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var coordinator: ConceptBookCoordinator?
    let rootView: ChapterDetailMainView
    private let chapterDetailVM: ChapterDetailViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialize
    
    init(chapterDetailVM: ChapterDetailViewModel) {
        self.chapterDetailVM = chapterDetailVM
        self.rootView = ChapterDetailMainView()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarTitle(title: chapterDetailVM.chapter.cardTitle)
        rootView.configure(with: chapterDetailVM.chapter)
    }
    
    override func loadView() {
        self.view = rootView
    }
}
