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
    
    weak var coordinator: MyPageCoordinator?
    private let rootView: MyPageMainView
    private let viewModel: MyPageViewModel
    private let inputSubject = PassthroughSubject<MyPageViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialize
    
    init(viewModel: MyPageViewModel) {
        self.rootView = MyPageMainView()
        self.viewModel = viewModel
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
        inputSubject.send(.viewDidLoad)
    }
    
    override func loadView() {
        self.view = rootView
    }
    
    // MARK: - Functions
    
    private func bind() {
        let viewDidLoad = inputSubject
        
        let menuTap = rootView.selectionPublisher
            .compactMap { item -> MyPageViewModel.Input? in
                switch item {
                case .supportMenu(.termsOfService): return .didTapTermsOfService
                case .supportMenu(.privacyPolicy):  return .didTapPrivacyPolicy
                default: return nil
                }
            }
        
        let input = viewDidLoad
            .merge(with: menuTap)
            .eraseToAnyPublisher()
        
        let output = viewModel.transform(input: input)
        
        output
            .sink { [weak self] output in
                guard let self else { return }
                
                switch output {
                case .setupView(let userName, let version):
                    self.rootView.applySnapshot(userName: userName, appVersion: version)
                    
                case .showTermsDetail(let termItem):
                    self.coordinator?.showTermsDetail(for: termItem)
                }
            }
            .store(in: &cancellables)
    }
}

