//
//  FindIdViewController.swift
//  QRIZ
//
//  Created by 김세훈 on 1/17/25.
//

import UIKit
import Combine

final class FindIdViewController: UIViewController {
    
    // MARK: - Enums
    
    private enum Attributes {
        static let navigationTitle: String = "아이디 찾기"
    }
    
    // MARK: - Properties
    
    private let rootView: FindAccountMainView
    private let findIdInputVM: FindIdViewModel
    private var cancellables = Set<AnyCancellable>()
    private var keyboardCancellable: AnyCancellable?
    
    // MARK: - initialize
    
    init(findIdInputVM: FindIdViewModel) {
        self.rootView = FindAccountMainView(type: .findId)
        self.findIdInputVM = findIdInputVM
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
        let emailTextChanged = rootView.findAccountInputView.textChangedPublisher
            .map { FindIdViewModel.Input.emailTextChanged($0) }
        
        let nextButtonTapped = rootView.signupFooterView.buttonTappedPublisher
            .map { FindIdViewModel.Input.buttonTapped }
        
        let input = Publishers.Merge(
            emailTextChanged,
            nextButtonTapped
        )
            .eraseToAnyPublisher()
        
        let output = findIdInputVM.transform(input: input)
        
        output
            .sink { [weak self] output in
                guard let self = self else { return }
                switch output {
                case .isNameValid(let isValid):
                    self.rootView.findAccountInputView.updateErrorState(isValid: isValid)
                    self.rootView.signupFooterView.updateButtonState(isValid: isValid)
                    
                case .navigateToAlerView:
                    // MARK: - 코디네이터 적용 필요
                    let alert = CustomAlertViewController()
                    alert.setAlertView(
                        alertView: CustomAlertView(
                            alertType: .onlyConfirm,
                            title: "이메일 발송 완료!",
                            description: "입력해주신 이메일 주소로아이디가\n발송되었습니다. 메일함을 확인해주세요.",
                            descriptionLine: 3
                        )
                    )
                    self.present(alert, animated: true)
                }
            }
            .store(in: &cancellables)
    }
    
    private func observe() {
        keyboardCancellable = observeKeyboardNotifications(for: rootView.signupFooterView)
        
        view.tapGestureEndedPublisher()
            .sink { [weak self] _ in
                self?.view.endEditing(true)
            }
            .store(in: &cancellables)
    }
}
