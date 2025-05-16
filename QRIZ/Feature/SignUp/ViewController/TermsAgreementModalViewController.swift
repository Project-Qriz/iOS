//
//  TermsAgreementModalViewController.swift
//  QRIZ
//
//  Created by 김세훈 on 5/13/25.
//

import UIKit
import Combine

final class TermsAgreementModalViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var coordinator: SignUpCoordinator?
    private let rootView: TermsAgreementModalMainView
    private let viewModel: TermsAgreementModalViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialize
    
    init(viewModel: TermsAgreementModalViewModel) {
        self.rootView = TermsAgreementModalMainView()
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    override func loadView() {
        self.view = rootView
    }
    
    // MARK: - Functions
    
    private func bind() {
        let exitButtonTapped = rootView.headerView.dismissButtonTappedPublisher.map { TermsAgreementModalViewModel.Input.dismissButtonTapped }
        
        let input = exitButtonTapped
            .eraseToAnyPublisher()
        
        let output = viewModel.transform(input: input)
        
        output
            .sink { [weak self] output in
                guard let self = self else { return }
                
                switch output {
                case .dismissModal:
                    self.dismiss(animated: true)
                }
            }
            .store(in: &cancellables)
    }
    
//    private func showOneButtonAlert() {
//        let oneButtonAlert = OneButtonCustomAlertViewController(
//            title: Attributes.alertTitle,
//            description: Attributes.alertDescription
//        )
//        oneButtonAlert.confirmButtonTappedPublisher
//            .sink { [weak self] _ in
//                oneButtonAlert.dismiss(animated: true) {
//                    guard let self = self,
//                          let coordinator = self.coordinator else { return }
//                    self.coordinator?.delegate?.didFinishSignUp(coordinator)
//                }
//            }
//            .store(in: &cancellables)
//        
//        present(oneButtonAlert, animated: true)
//    }
}
