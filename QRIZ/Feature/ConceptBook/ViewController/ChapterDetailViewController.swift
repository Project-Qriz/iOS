//
//  ChapterDetailViewController.swift
//  QRIZ
//
//  Created by 김세훈 on 4/18/25.
//

import UIKit

final class ChapterDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    private let chapterDetailVM: ChapterDetailViewModel
    
    // MARK: - Initialize
    
    init(chapterDetailVM: ChapterDetailViewModel) {
        self.chapterDetailVM = chapterDetailVM
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
        
        print(chapterDetailVM.chapter)
        print(chapterDetailVM.chapter.concepts)
    }
}
