//
//  LoginViewController.swift
//  QRIZ
//
//  Created by KSH on 12/19/24.
//

import UIKit

final class LoginViewController: UIViewController {
    
    // MARK: - Properties
    
    private let rootView: LoginMainView
    
    // MARK: - initialize
    
    init() {
        self.rootView = LoginMainView()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        self.view = rootView
    }
}
