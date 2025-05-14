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
    
    // MARK: - Initialize
    
    init() {
        self.rootView = TermsAgreementModalMainView()
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
