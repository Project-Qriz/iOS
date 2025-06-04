//
//  SplashViewController.swift
//  QRIZ
//
//  Created by 김세훈 on 6/2/25.
//

import UIKit
import Combine

final class SplashViewController: UIViewController {
    
    // MARK: - Properties
    
    private let rootView: SplashMainView
    private let viewModel: SplashViewModel
    private let inputSubject = PassthroughSubject<SplashViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    var didFinish: ((Bool) -> Void)?
    
    // MARK: - Initialize
    
    init(viewModel: SplashViewModel) {
        self.rootView = SplashMainView()
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        inputSubject.send(.viewDidAppear)
    }
    
    // MARK: - Functions
    
    private func bind() {
        let output = viewModel.transform(input: inputSubject.eraseToAnyPublisher())
        
        output
            .sink { [weak self] event in
                switch event {
                case .finished(let isLoggedIn):
                    self?.didFinish?(isLoggedIn)
                }
            }
            .store(in: &cancellables)
    }
}
