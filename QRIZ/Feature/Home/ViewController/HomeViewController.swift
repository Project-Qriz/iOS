//
//  HomeViewController.swift
//  QRIZ
//
//  Created by ch on 12/10/24.
//

import UIKit
import Combine

final class HomeViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var coordinator: HomeCoordinator?
    private let rootView: HomeMainView
    private let HomeVM: HomeViewModel
    private let inputSubject = PassthroughSubject<HomeViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialize
    
    init(homeVM: HomeViewModel) {
        self.rootView = HomeMainView()
        self.HomeVM = homeVM
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        setupNavigationBar()
        inputSubject.send(.viewDidLoad)
    }
    
    override func loadView() {
        self.view = rootView
    }
    
    // MARK: - Functions
    
    private func bind() {
        let output = HomeVM.transform(input: inputSubject.eraseToAnyPublisher())
        
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                guard let self else { return }
                
                switch output {
                case .showRegistered(let item):
                    self.rootView.applySnapshot(registered: item)
                    
                case .showNotRegistered(let user):
                    self.rootView.applySnapshot(notRegisteredFor: user)
                    
                case .showExpired(let user):
                    self.rootView.applySnapshot(expiredFor: user)
                    
                case .showErrorAlert(let message):
                    self.showOneButtonAlert(with: message, storingIn: &cancellables)
                }
            }
            .store(in: &cancellables)
        
        rootView.examButtonTappedPublisher
            .sink { [weak self] in self?.coordinator?.showExamSelectionSheet() }
            .store(in: &cancellables)
    }
    
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        let imageView = UIImageView(image: .homeLogo)
        imageView.contentMode = .scaleAspectFit
        
        let logoItem = UIBarButtonItem(customView: imageView)
        navigationItem.leftBarButtonItem = logoItem
    }
}

