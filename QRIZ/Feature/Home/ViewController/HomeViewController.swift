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
    private let viewModel: HomeViewModel
    private let inputSubject = PassthroughSubject<HomeViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialize
    
    init(homeVM: HomeViewModel) {
        self.rootView = HomeMainView()
        self.viewModel = homeVM
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
        bind()
        setupNavigationBar()
        inputSubject.send(.viewDidLoad)
    }
    
    // MARK: - Functions
    
    private func bind() {
        let viewDidLoad = Just(HomeViewModel.Input.viewDidLoad)
        
        let entryTapped = rootView.entryTappedPublisher.map { HomeViewModel.Input.entryTapped }
        
        let input = viewDidLoad
            .merge(with: entryTapped)
            .eraseToAnyPublisher()
        
        let output = viewModel.transform(input: input)
        
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                guard let self else { return }
                
                switch output {
                case .updateState(let state):
                    self.rootView.apply(state)
                    
                case .showErrorAlert(let message):
                    self.showOneButtonAlert(with: message, storingIn: &cancellables)
                    
                case .navigateToOnboarding:
                    self.coordinator?.showOnboarding()
                    
                case .navigateToExamList:
                    // TODO: - Coordinator 연결 필요
                    print("Coordinator 연결")
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

