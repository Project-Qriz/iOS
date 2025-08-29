//
//  SocialLoginView.swift
//  QRIZ
//
//  Created by KSH on 12/22/24.
//

import UIKit
import Combine

final class SocialLoginView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let separatorHeight: CGFloat = 1.0
        static let roundButtonSize: CGFloat = 44.0
        static let socialLoginHStackViewTopOffset: CGFloat = 12.0
    }
    
    private enum Attributes {
        static let socialLoginLabelText: String = "다른 방법으로 로그인하기"
    }
    
    // MARK: - Properties
    
    private let socialLoginTapSubject = PassthroughSubject<LoginViewModel.SocialLogin, Never>()
    
    var socialLoginPublisher: AnyPublisher<LoginViewModel.SocialLogin, Never> {
        socialLoginTapSubject.eraseToAnyPublisher()
    }
    
    // MARK: - UI
    
    private let socialLoginLabel: UILabel = {
        let label = UILabel()
        label.text = Attributes.socialLoginLabelText
        label.textColor = .coolNeutral400
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .center
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    private lazy var separatorHStackView: UIStackView = {
        let leftSeparator = buildSeparator()
        let rightSeparator = buildSeparator()
        let stackView = UIStackView(arrangedSubviews: [
            leftSeparator,
            socialLoginLabel,
            rightSeparator
        ])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.distribution = .fill
        leftSeparator.widthAnchor.constraint(equalTo: rightSeparator.widthAnchor).isActive = true
        return stackView
    }()
    
    private lazy var socialLoginHStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            buildButton(socialLogin: .google),
            buildButton(socialLogin: .kakao),
            buildButton(socialLogin: .apple)
        ])
        stackView.axis = .horizontal
        stackView.spacing = 20
        return stackView
    }()
    
    
    // MARK: - initialize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    private func buildSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = .coolNeutral200
        separator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            separator.heightAnchor.constraint(equalToConstant: Metric.separatorHeight)
        ])
        return separator
    }
    
    private func buildButton(socialLogin: LoginViewModel.SocialLogin) -> UIButton {
        let button = RoundButton()
        let image = UIImage(named: socialLogin.logoName)
        button.setImage(image, for: .normal)
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = socialLogin == .google ? UIColor.coolNeutral100.cgColor : UIColor.clear.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: Metric.roundButtonSize),
            button.heightAnchor.constraint(equalToConstant: Metric.roundButtonSize)
        ])
        
        button.addAction(UIAction { [weak self] _ in
            self?.socialLoginTapSubject.send(socialLogin)
        }, for: .touchUpInside)
        return button
    }
}

// MARK: - Layout Setup

extension SocialLoginView {
    private func addSubviews() {
        [
            separatorHStackView,
            socialLoginHStackView
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        separatorHStackView.translatesAutoresizingMaskIntoConstraints = false
        socialLoginHStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            separatorHStackView.topAnchor.constraint(equalTo: topAnchor),
            separatorHStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorHStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            socialLoginHStackView.topAnchor.constraint(equalTo: separatorHStackView.bottomAnchor, constant: Metric.socialLoginHStackViewTopOffset),
            socialLoginHStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            socialLoginHStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
