//
//  DaySelectSheetViewController.swift
//  QRIZ
//
//  Created by 김세훈 on 7/12/25.
//

import UIKit
import Combine

final class DaySelectBottomSheetViewController: UIViewController {
    
    // MARK: - Properties
    
    private let rootView: DaySelectBottomSheetMainView
    private let viewModel: DaySelectBottomSheetViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialize
    
    init(viewModel: DaySelectBottomSheetViewModel) {
        self.rootView = DaySelectBottomSheetMainView()
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
    }
    
    // MARK: - Functions
    
    private func bind() {
        let viewDidLoad = Just(DaySelectBottomSheetViewModel.Input.viewDidLoad)
        let dayTap = rootView.dayTapPublisher
            .map { DaySelectBottomSheetViewModel.Input.dayTapped($0) }
        
        let prevTap = rootView.prevTapPublisher
            .map { DaySelectBottomSheetViewModel.Input.prevWeekTapped }
        
        let nextTap = rootView.nextTapPublisher
            .map { DaySelectBottomSheetViewModel.Input.nextWeekTapped }
        
        let todayTap = rootView.todayTapPublisher
            .map { DaySelectBottomSheetViewModel.Input.todayTapped }

        let input = viewDidLoad
            .merge(with: dayTap)
            .merge(with: prevTap)
            .merge(with: nextTap)
            .merge(with: todayTap)
            .eraseToAnyPublisher()

        let output = viewModel.transform(input: input)
        
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                guard let self else { return }
                
                switch output {
                case .updateUI(let week, let selected,let totalDays, let prevE, let nextE):
                    rootView.updateWeek(week)
                    rootView.updateArrows(prevEnabled: prevE, nextEnabled: nextE)
                    rootView.reloadCollectionView(selected: selected, totalDays: totalDays)

                case .updateSelectedDay(let selected, let totalDays):
                    rootView.reloadCollectionView(selected: selected, totalDays: totalDays)
                }
            }
            .store(in: &cancellables)
    }
    
}

