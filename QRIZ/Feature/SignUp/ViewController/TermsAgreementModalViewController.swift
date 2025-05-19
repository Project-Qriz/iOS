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
        let dismissButtonTapped = rootView.headerView.dismissButtonTappedPublisher.map { TermsAgreementModalViewModel.Input.dismissButtonTapped }
        
        let allToggle = rootView.allAgreeView.checkBoxButtonTappedPublisher
            .scan(false) { last, _ in !last }
            .map { TermsAgreementModalViewModel.Input.allToggle($0) }
        
        let itemToggle = rootView.cellTapPublisher
            .map { TermsAgreementModalViewModel.Input.termToggle(index: $0) }
        
        let detailTapped = rootView.detailTapPublisher
            .map { TermsAgreementModalViewModel.Input.showDetail(index: $0) }
        
        let signUpButtonTapped = rootView.footerView.buttonTappedPublisher
            .map { TermsAgreementModalViewModel.Input.signUpButtonTapped }
        
        let input = dismissButtonTapped
            .merge(with: allToggle)
            .merge(with: itemToggle)
            .merge(with: detailTapped)
            .merge(with: signUpButtonTapped)
            .eraseToAnyPublisher()
        
        let output = viewModel.transform(input: input)
        
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                guard let self = self else { return }
                
                switch output {
                case .initialTerms(let terms):
                    self.rootView.configureItems(items: terms)
                    
                case .dismissModal:
                    self.coordinator?.dismissView()
                    
                case .allAgreeChanged(let isOn):
                    self.rootView.allAgreeView.setChecked(isOn)
                    
                case .termChanged(let index, let on):
                    self.rootView.updateItemCheck(at: index, on: on)
                    
                case .updateSignUpButtonState(let canSignUp):
                    self.rootView.footerView.updateButtonState(isValid: canSignUp)
                    
                case .showTermsDetail(let index):
                    break
                    
                case .showErrorAlert(let title, let description):
                    self.showOneButtonAlert(with: title, for: description, storingIn: &cancellables)
                    
                case .signUpSucceeded:
                    self.coordinator?.showSignUpCompleteAlert()
                }
            }
            .store(in: &cancellables)
    }
}
