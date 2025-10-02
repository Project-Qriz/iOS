//
//  ExamScheduleSelectionViewController.swift
//  QRIZ
//
//  Created by 김세훈 on 5/2/25.
//

import UIKit
import Combine

final class ExamScheduleSelectionViewController: UIViewController {
    
    // MARK: - Properties
    
    private let rootView: ExamScheduleSelectionMainView
    private let examScheduleSelectionVM: ExamScheduleSelectionViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialize
    
    init(examScheduleSelectionVM: ExamScheduleSelectionViewModel) {
        self.rootView = ExamScheduleSelectionMainView()
        self.examScheduleSelectionVM = examScheduleSelectionVM
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
        let viewDidLoad = Just(ExamScheduleSelectionViewModel.Input.viewDidLoad)
            .eraseToAnyPublisher()
        
        let examTapped = rootView.examTappedPublisher
            .map { ExamScheduleSelectionViewModel.Input.examTapped($0) }
            .eraseToAnyPublisher()
        
        let input = viewDidLoad
            .merge(with: examTapped)
            .eraseToAnyPublisher()
        
        let output = examScheduleSelectionVM.transform(input: input)
        
        output
            .sink { [weak self] output in
                guard let self else { return }
                
                switch output {
                case .loadExamList(let rows):
                    self.rootView.updateExamList(rows: rows)
                    
                case .showErrorAlert(let message):
                    self.showOneButtonAlert(with: message, storingIn: &cancellables)
                }
            }
            .store(in: &cancellables)
    }
    
}
