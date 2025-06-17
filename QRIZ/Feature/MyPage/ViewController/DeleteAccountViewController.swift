//
//  DeleteAccountViewController.swift
//  QRIZ
//
//  Created by 김세훈 on 6/16/25.
//

import UIKit
import Combine

final class DeleteAccountViewController: UIViewController {
    
    // MARK: - Enums
    
    private enum Attributes {
        static let navigationTitle: String = "회원 탈퇴"
    }
    
    // MARK: - Properties
    
    weak var coordinator: MyPageCoordinator?
    private let rootView: DeleteAccountMainView
    private let viewModel: DeleteAccountViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialize
    
    init(viewModel: DeleteAccountViewModel) {
        self.rootView = DeleteAccountMainView()
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
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
        setNavigationBarTitle(title: Attributes.navigationTitle)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.hidesBottomBarWhenPushed = false
    }
    
    // MARK: - Functions
    
    private func bind() {
    }
}
