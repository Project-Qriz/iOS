//
//  HomeViewController.swift
//  QRIZ
//
//  Created by ch on 12/10/24.
//

import UIKit
import DesignSystem
import Combine

@MainActor
final class HomeViewController: UIViewController {

    // MARK: - Properties

    weak var coordinator: HomeCoordinator?
    private let rootView: HomeMainView
    private let viewModel: HomeViewModel
    private let inputSubject = PassthroughSubject<HomeViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(viewModel: HomeViewModel) {
        self.rootView = HomeMainView()
        self.viewModel = viewModel
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if coordinator?.needsRefresh == true {
            coordinator?.needsRefresh = false
            inputSubject.send(.viewDidLoad)
        }
    }
    
    // MARK: - Methods

    private func bind() {
        let entryTapped = rootView.entryTappedPublisher.map { HomeViewModel.Input.entryTapped }
        let pageChanged = rootView.selectedIndexPublisher.map { HomeViewModel.Input.daySelected($0) }
        let resetTapped = rootView.resetButtonTappedPublisher.map { HomeViewModel.Input.planChangeTapped }
        let headerTapped = rootView.dayHeaderTappedPublisher.map { HomeViewModel.Input.dayHeaderTapped }
        let ctaTapped = rootView.studyButtonTappedPublisher.map { HomeViewModel.Input.ctaTapped(day: $0) }
        let weeklyConceptTapped = rootView.weeklyConceptTappedPublisher.map { HomeViewModel.Input.weeklyConceptTapped($0) }

        let input = inputSubject
            .merge(with: entryTapped)
            .merge(with: pageChanged)
            .merge(with: resetTapped)
            .merge(with: headerTapped)
            .merge(with: ctaTapped)
            .merge(with: weeklyConceptTapped)
            .eraseToAnyPublisher()

        let output = viewModel.transform(input: input)

        output
            .sink { [weak self] output in
                guard let self else { return }

                switch output {
                case .updateState(let state):
                    rootView.apply(state)

                case .showErrorAlert(let title, let description):
                    showOneButtonAlert(
                        with: title,
                        for: description,
                        storingIn: &cancellables
                    )

                case .navigateToOnboarding:
                    coordinator?.showOnboarding()

                case .navigateToExamList:
                    coordinator?.showExam()

                case .showDaySelectAlert(let total, let selected, let today):
                    coordinator?.showDaySelectAlert(
                        totalDays: total,
                        selectedDay: selected,
                        todayIndex: today
                    )

                case .showPlanChange(let totalDays):
                    coordinator?.showPlanChange(totalDays: totalDays, onResetRequested: { [weak self] in
                        self?.inputSubject.send(.resetTapped)
                    })

                case .showResetAlert:
                    coordinator?.showResetAlert { [weak self] in
                        self?.inputSubject.send(.didConfirmResetPlan)
                    }

                case .resetSucceeded(let message):
                    showOneButtonAlert(with: message, storingIn: &cancellables)

                case .showDaily(let day, let type):
                    coordinator?.showDaily(day: day, type: type)

                case .showConceptPDF(let chapter, let item):
                    coordinator?.showConceptPDF(chapter: chapter, conceptItem: item)
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
