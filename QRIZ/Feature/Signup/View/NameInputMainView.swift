//
//  NameInputMainView.swift
//  QRIZ
//
//  Created by 김세훈 on 12/31/24.
//

import UIKit

final class NameInputMainView: UIView {
    
    // MARK: - Enums
    
    private enum Attributes {
        static let headerTitle: String = "이름을 입력해주세요!"
        static let headerDescription: String = "가입을 위해 실명을 입력해주세요."
        static let progressValue: Float = 0.25
    }
    
    // MARK: - Properties
    
    let signupHeaderView = SignupHeaderView()
    
    // MARK: - initialize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setupConstraints()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    private func setupUI() {
        self.backgroundColor = .white
        signupHeaderView.configure(
            title: Attributes.headerTitle,
            description: Attributes.headerDescription,
            progress: Attributes.progressValue
        )
    }
}

// MARK: - Layout Setup

extension NameInputMainView {
    private func addSubviews() {
        [
            signupHeaderView
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        signupHeaderView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            signupHeaderView.topAnchor.constraint(equalTo: topAnchor),
            signupHeaderView.leadingAnchor.constraint(equalTo: leadingAnchor),
            signupHeaderView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
}
