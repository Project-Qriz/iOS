//
//  AccountOptionsView.swift
//  QRIZ
//
//  Created by KSH on 12/22/24.
//

import UIKit

final class AccountOptionsView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let separatorWidth: CGFloat  = 1.0
        static let separatorHeight: CGFloat = 14.0
    }
    
    private enum Attributes {
        static let findIdButtonTitle = "아이디 찾기"
        static let findPasswordButtonTitle = "비밀번호 찾기"
        static let signUpButtonTitle = "회원가입"
    }
    
    // MARK: - UI
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                buildButton(title: Attributes.findIdButtonTitle),
                buildSeparator(),
                buildButton(title: Attributes.findPasswordButtonTitle),
                buildSeparator(),
                buildButton(title: Attributes.signUpButtonTitle)
            ]
        )
        stackView.axis = .horizontal
        stackView.spacing = 12
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
    
    private func buildButton(title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.setTitleColor(.coolNeutral500, for: .normal)
        button.addAction(UIAction { _ in
            print(button.titleLabel?.text ?? "타이틀이 없는 버튼")
        }, for: .touchUpInside)
        return button
    }
    
    private func buildSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = .coolNeutral200
        separator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            separator.widthAnchor.constraint(equalToConstant: Metric.separatorWidth),
            separator.heightAnchor.constraint(equalToConstant: Metric.separatorHeight)
        ])
        return separator
    }
}

// MARK: - Layout Setup

extension AccountOptionsView {
    private func addSubviews() {
        addSubview(stackView)
    }
    
    private func setupConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
