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
//        Task {
//            let a = try await DailyServiceImpl().getDailyPlan()
//            print(a)
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if coordinator?.needsRefresh == true {
            coordinator?.needsRefresh = false
            inputSubject.send(.viewDidLoad)
        }
    }
    
    // MARK: - Functions
    
    private func bind() {
        let entryTapped = rootView.entryTappedPublisher.map { HomeViewModel.Input.entryTapped }
        let pageChanged  = rootView.selectedIndexPublisher.map { HomeViewModel.Input.daySelected($0) }
        let resetTapped = rootView.resetButtonTappedPublisher.map { HomeViewModel.Input.resetTapped }
        let headerTapped = rootView.dayHeaderTappedPublisher.map { HomeViewModel.Input.dayHeaderTapped }
        let ctaTapped  = rootView.studyButtonTappedPublisher.map { HomeViewModel.Input.ctaTapped(day: $0) }
        
        let input = inputSubject
            .merge(with: entryTapped)
            .merge(with: pageChanged)
            .merge(with: resetTapped)
            .merge(with: headerTapped)
            .merge(with: ctaTapped)
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
                    self.coordinator?.showExam()
                    
                case .showDaySelectAlert(let total, let selected, let today):
                    coordinator?.showDaySelectAlert(
                        totalDays: total,
                        selectedDay: selected,
                        todayIndex: today
                    )
                    
                case .showResetAlert:
                    self.coordinator?.showResetAlert { self.inputSubject.send(.didConfirmResetPlan) }
                    
                case .resetSucceeded(let message):
                    self.showOneButtonAlert(with: message, storingIn: &cancellables)
                    
                case .showDaily(let day, let type):
                    self.coordinator?.showDaily(day: day, type: type)
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
    
    func handleDaySelected(_ day: Int) {
        inputSubject.send(.daySelected(day))
    }
}

