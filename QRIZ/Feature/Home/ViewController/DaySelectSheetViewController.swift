//
//  DaySelectSheetViewController.swift
//  QRIZ
//
//  Created by 김세훈 on 7/12/25.
//

import UIKit
import Combine

final class DaySelectBottomSheetViewController: UIViewController {
    
    // MARK: - Properties
    
    private let rootView: DaySelectBottomSheetMainView
    private let viewModel: DaySelectBottomSheetViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialize
    
    init(viewModel: DaySelectBottomSheetViewModel) {
        self.rootView = DaySelectBottomSheetMainView()
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    
    override func loadView() {
        self.view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    // MARK: - Functions
    
    private func bind() {
    }
    
}

