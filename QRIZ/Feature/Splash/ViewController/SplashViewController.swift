//
//  SplashViewController.swift
//  QRIZ
//
//  Created by 김세훈 on 6/2/25.
//

import UIKit

final class SplashViewController: UIViewController {
    
    // MARK: - Properties
    
    private let rootView: SplashMainView
    
    // MARK: - Initialize
    
    init() {
        self.rootView = SplashMainView()
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
    }
}
