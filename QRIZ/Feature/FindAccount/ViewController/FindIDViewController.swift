//
//  FindIDViewController.swift
//  QRIZ
//
//  Created by 김세훈 on 1/17/25.
//

import UIKit
import Combine

final class FindIDViewController: UIViewController {
    
    // MARK: - Enums
    
    private enum Attributes {
        static let navigationTitle: String = "아이디 찾기"
        static let alertTitle: String = "이메일 발송 완료!"
        static let alertDescription: String = "입력하신 이메일 주소로 비밀번호가\n발송되었습니다. 메일함을 확인해주세요."
    }
    
    // MARK: - Properties
    
    weak var coordinator: LoginCoordinator?
    private let rootView: FindIDMainView
    private let findIDInputVM: FindIDViewModel
    private var cancellables = Set<AnyCancellable>()
    private var keyboardCancellable: AnyCancellable?
    
    // MARK: - initialize
    
    init(findIDInputVM: FindIDViewModel) {
        self.rootView = FindIDMainView()
        self.findIDInputVM = findIDInputVM
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarTitle(title: Attributes.navigationTitle)
        bind()
        observe()
    }
    
    override func loadView() {
        self.view = rootView
    }
    
    deinit {
        keyboardCancellable?.cancel()
    }
    
    // MARK: - Functions
    
    private func bind() {
        let emailTextChanged = rootView.findIDInputView.textChangedPublisher
            .map { FindIDViewModel.Input.emailTextChanged($0) }
        
        let nextButtonTapped = rootView.signUpFooterView.buttonTappedPublisher
            .map { FindIDViewModel.Input.buttonTapped }
        
        let input = Publishers.Merge(
            emailTextChanged,
            nextButtonTapped
        )
            .eraseToAnyPublisher()
        
        let output = findIDInputVM.transform(input: input)
        
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                guard let self = self else { return }
                switch output {
                case .isNameValid(let isValid):
                    self.rootView.findIDInputView.updateErrorState(isValid: isValid)
                    self.rootView.signUpFooterView.updateButtonState(isValid: isValid)
                    
                case .showErrorAlert(let errorMessage):
                    self.showErrorAlert(with: errorMessage, storingIn: &cancellables)
                    
                case .navigateToAlerView:
                    self.showOneButtonAlert()
                }
            }
            .store(in: &cancellables)
    }
    
    private func observe() {
        keyboardCancellable = observeKeyboardNotifications(for: rootView.signUpFooterView)
        
        view.tapGestureEndedPublisher()
            .sink { [weak self] _ in
                self?.view.endEditing(true)
            }
            .store(in: &cancellables)
    }
    
    private func showOneButtonAlert() {
        let oneButtonAlert = OneButtonCustomAlertViewController(
            title: Attributes.alertTitle,
            description: Attributes.alertDescription
        )
        oneButtonAlert.confirmButtonTappedPublisher
            .sink { [weak self] _ in
                oneButtonAlert.dismiss(animated: true) {
                    guard let self = self else { return }
                    self.coordinator?.popToRootViewController()
                }
            }
            .store(in: &cancellables)
        
        present(oneButtonAlert, animated: true)
    }
}
