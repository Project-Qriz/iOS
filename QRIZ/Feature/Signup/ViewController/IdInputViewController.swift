//
//  IdInputViewController.swift
//  QRIZ
//
//  Created by 김세훈 on 1/3/25.
//

import UIKit
import Combine

final class IdInputViewController: UIViewController {
    
    // MARK: - Properties
    
    private let rootView: IdInputMainView
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - initialize
    
    init() {
        self.rootView = IdInputMainView()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    override func loadView() {
        self.view = rootView
    }
    
    // MARK: - Functions
    
    private func bind() {
    }
}
