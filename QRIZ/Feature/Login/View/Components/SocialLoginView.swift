//
//  SocialLoginView.swift
//  QRIZ
//
//  Created by KSH on 12/22/24.
//

import UIKit

final class SocialLoginView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let separatorHeight: CGFloat = 1.0
        static let roundButtonSize: CGFloat = 48.0
        static let socialLoginHStackViewTopOffset: CGFloat = 12.0
    }
    
    private enum Attributes {
        static let socialLoginLabelText: String = "다른 방법으로 로그인하기"
        static let googleLoginButtonTitle: String = "구글"
        static let naverLoginButtonTitle: String = "네이버"
        static let facebookLoginButtonTitle: String = "페북"
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
            buildButton(title: Attributes.googleLoginButtonTitle),
            buildButton(title: Attributes.naverLoginButtonTitle),
            buildButton(title: Attributes.facebookLoginButtonTitle)
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
    
    private func buildButton(title: String) -> UIButton {
        let button = RoundButton()
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16.8, weight: .regular)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .coolNeutral500
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: Metric.roundButtonSize),
            button.heightAnchor.constraint(equalToConstant: Metric.roundButtonSize)
        ])
        
        button.addAction(UIAction { _ in
            print(button.titleLabel?.text ?? "타이틀이 없는 버튼")
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

