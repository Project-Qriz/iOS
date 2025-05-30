//
//  MyPageViewController.swift
//  QRIZ
//
//  Created by 김세훈 on 2/23/25.
//

import UIKit
import Combine

final class MyPageViewController: UIViewController {
    
    // MARK: - Enums
    
    private enum Attributes {
        static let navigationTitle: String = "마이페이지"
    }
    
    // MARK: - Properties
    
    weak var coordinator: HomeCoordinator?
    private let rootView: MyPageMainView
    
    // MARK: - Initialize
    
    init() {
        self.rootView = MyPageMainView()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        setNavigationBarTitle(title: Attributes.navigationTitle)
    }
    
    override func loadView() {
        self.view = rootView
    }
    
    // MARK: - Functions
    
    private func bind() {
    }
}

