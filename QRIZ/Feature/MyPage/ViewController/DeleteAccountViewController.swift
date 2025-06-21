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
    private let inputSubject = PassthroughSubject<DeleteAccountViewModel.Input, Never>()
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
    
    // MARK: - Functions
    
    private func bind() {
        let didTapDeleteButton  = rootView.deleteTapPublisher
            .map { DeleteAccountViewModel.Input.didTapDelete }
        
        let input = inputSubject
            .merge(with: didTapDeleteButton)
            .eraseToAnyPublisher()
        
        let output = viewModel.transform(input: input)
        
        output
            .sink { [weak self] output in
                guard let self = self else { return }
                switch output {
                case .showConfirmAlert:
                    self.coordinator?.showConfirmDeleteAlert {
                        self.inputSubject.send(.didConfirmDelete)
                    }
                    
                case .deletionSucceeded:
                    guard let coord = self.coordinator else { return }
                    coord.delegate?.myPageCoordinatorDidLogout(coord)
                    
                case .showErrorAlert(let message):
                    self.showOneButtonAlert(with: message, storingIn: &self.cancellables)
                }
            }
            .store(in: &cancellables)
        
    }
}
