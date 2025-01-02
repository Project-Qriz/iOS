//
//  VerificationCodeViewController.swift
//  QRIZ
//
//  Created by 김세훈 on 1/1/25.
//

import UIKit
import Combine

final class VerificationCodeViewController: UIViewController {
    
    // MARK: - Properties
    
    private let rootView: VerificationCodeMainView
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - initialize
    
    init() {
        self.rootView = VerificationCodeMainView()
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
