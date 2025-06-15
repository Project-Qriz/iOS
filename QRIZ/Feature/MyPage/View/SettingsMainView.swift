//
//  SettingsMainView.swift
//  QRIZ
//
//  Created by 김세훈 on 6/15/25.
//

import UIKit
import Combine

final class SettingsMainView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let headerViewTopOffset: CGFloat = 24.0
        static let horizontalSpacing: CGFloat = 18.0
    }
    
    // MARK: - Properties
    
    // MARK: - UI
    
    let profileHeaderView = ProfileHeaderView()
    
    // MARK: - Initialize
    
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
        backgroundColor = .white
    }
}

// MARK: - Layout Setup

extension SettingsMainView {
    private func addSubviews() {
        [
            profileHeaderView
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        profileHeaderView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            [
                profileHeaderView.topAnchor.constraint(
                    equalTo: safeAreaLayoutGuide.topAnchor,
                    constant: Metric.headerViewTopOffset
                ),
                profileHeaderView.leadingAnchor.constraint(
                    equalTo: leadingAnchor,
                    constant: Metric.horizontalSpacing
                ),
                profileHeaderView.trailingAnchor.constraint(
                    equalTo: trailingAnchor,
                    constant: -Metric.horizontalSpacing
                ),
            ]
        )
    }
}


