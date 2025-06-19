//
//  SettingsViewController.swift
//  QRIZ
//
//  Created by 김세훈 on 6/15/25.
//

import UIKit
import Combine

final class SettingsViewController: UIViewController {
    
    // MARK: - Enums
    
    private enum Attributes {
        static let navigationTitle: String = "설정"
    }
    
    // MARK: - Properties
    
    weak var coordinator: MyPageCoordinator?
    private let rootView: SettingsMainView
    private let viewModel: SettingsViewModel
    private let inputSubject = PassthroughSubject<SettingsViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialize
    
    init(viewModel: SettingsViewModel) {
        self.rootView = SettingsMainView()
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
        inputSubject.send(.viewDidLoad)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.hidesBottomBarWhenPushed = false
    }
    
    // MARK: - Functions
    
    private func bind() {
        let viewDidLoad = inputSubject
        
        let optionTap = rootView.optionTapPublisher
            .compactMap { option -> SettingsViewModel.Input? in
                switch option {
                case .resetPassword: return .didTapResetPassword
                case .logout: return .didTapLogout
                case .deleteAccount: return .didTapDeleteAccount
                }
            }
        
        let input = viewDidLoad
            .merge(with: optionTap)
            .eraseToAnyPublisher()
        
        let output = viewModel.transform(input: input)
        
        output.sink { [weak self] output in
            guard let self else { return }
            
            switch output {
            case .setupProfile(let userName, let email):
                rootView.profileHeaderView.configure(name: userName, email: email)
                
            case .navigateToResetPassword:
                print("패스워드 뷰 이동")
                
            case .showLogoutAlert:
                self.coordinator?.showLogoutAlert()
                
            case .navigateToDeleteAccount:
                self.coordinator?.showDeleteAccount()
            }
        }.store(in: &cancellables)
    }
}

