//
//  NameInputViewController.swift
//  QRIZ
//
//  Created by 김세훈 on 12/31/24.
//

import UIKit
import Combine

final class NameInputViewController: UIViewController {
    
    // MARK: - Enums
    
    private enum Attributes {
        static let headerTitle: String = "이름을 입력해주세요!"
        static let headerDescription: String = "가입을 위해 실명을 입력해주세요."
        static let footerTitle: String = "다음"
        static let progressValue: Float = 0.25
        static let inputPlaceholder: String = "이름을 입력"
        static let inputErrorText: String = "이름을 다시 확인해 주세요."
    }
    
    // MARK: - Properties
    
    private let rootView: SingleInputMainView
    private let nameInputVM: NameInputViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - initialize
    
    init(nameInputVM: NameInputViewModel) {
        self.rootView = SingleInputMainView(
            title: Attributes.headerTitle,
            description: Attributes.headerDescription,
            progressValue: Attributes.progressValue,
            buttonTitle: Attributes.footerTitle,
            inputPlaceholder: Attributes.inputPlaceholder,
            inputErrorText: Attributes.inputErrorText
        )
        self.nameInputVM = nameInputVM
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
        let nameTextChanged = rootView.singleInputView.nameTextChangedPublisher
            .map { NameInputViewModel.Input.nameTextChanged($0) }
            .eraseToAnyPublisher()
        
        let output = nameInputVM.transform(input: nameTextChanged)
        
        output
            .sink { [weak self] output in
                guard let self = self else { return }
                switch output {
                case .isNameValid(let isValid):
                    self.rootView.singleInputView.updateErrorState(isValid: isValid)
                    self.rootView.signupFooterView.updateButtonState(isValid: isValid)
                }
            }
            .store(in: &cancellables)
    }
}

