//
//  IdInputView.swift
//  QRIZ
//
//  Created by 김세훈 on 1/3/25.
//

import UIKit
import Combine

final class IdInputView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let stackViewHeight: CGFloat = 48.0
        static let buttonWidthMultiplier: CGFloat = 1.9
        static let idCountLabelTopOffset: CGFloat = 8.0
    }
    
    private enum Attributes {
        static let placeholder: String = "아이디 입력"
        static let buttonTitle: String = "중복확인"
        static let noticeLabelText: String = "0/8"
    }
    
    // MARK: - Properties
    
    private let buttonTappedSubject = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    var buttonTappedPublisher: AnyPublisher<Void, Never> {
        buttonTappedSubject.eraseToAnyPublisher()
    }
    
    var textChangedPublisher: AnyPublisher<String, Never> {
        idTextField.textPublisher
    }
    
    // MARK: - UI
    
    private let idTextField: UITextField = CustomTextField(placeholder: Attributes.placeholder)
    
    private lazy var duplicateCheckButton: UIButton = {
        let button = UIButton()
        button.setTitle(Attributes.buttonTitle, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.setTitleColor(.customBlue500, for: .normal)
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 8
        button.layer.borderColor = UIColor.customBlue500.cgColor
        button.layer.masksToBounds = true
        button.addAction(UIAction { [weak self] _ in
            self?.buttonTappedSubject.send()
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            idTextField,
            duplicateCheckButton
        ])
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 8
        return stackView
    }()
    
    private let noticeLabel: UILabel = {
        let label = UILabel()
        label.text = Attributes.noticeLabelText
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .coolNeutral800
        return label
    }()
    
    // MARK: - initialize
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        addSubviews()
        setupConstraints()
        setupUI()
        observe()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    private func setupUI() {
        self.backgroundColor = .white
    }
    
    private func observe() {
        idTextField.controlEventPublisher(for: .editingDidEndOnExit)
            .sink { [weak self] _ in
                self?.resignFirstResponder()
            }
            .store(in: &cancellables)
    }
    
    func updateCheckMessage(message: String, isAvailable: Bool) {
        noticeLabel.text = message
        noticeLabel.textColor = isAvailable ? .customMint800 : .customRed500
        idTextField.layer.borderColor = isAvailable ? UIColor.customMint800.cgColor : UIColor.customRed500.cgColor
    }
    
    func updateTextCountLabel(current: Int, min: Int) {
        noticeLabel.text = "\(current)/\(min)"
    }
    
    func resetColors() {
        noticeLabel.textColor = .coolNeutral800
        idTextField.layer.borderColor = UIColor.clear.cgColor
    }
}

// MARK: - Layout Setup

extension IdInputView {
    private func addSubviews() {
        [
            stackView,
            noticeLabel
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        noticeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.heightAnchor.constraint(equalToConstant: Metric.stackViewHeight),
            
            duplicateCheckButton.widthAnchor.constraint(equalTo: duplicateCheckButton.heightAnchor, multiplier: Metric.buttonWidthMultiplier),
            
            noticeLabel.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: Metric.idCountLabelTopOffset),
            noticeLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            noticeLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            noticeLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
