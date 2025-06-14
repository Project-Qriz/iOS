//
//  SettingsMainView.swift
//  QRIZ
//
//  Created by 김세훈 on 6/15/25.
//

import UIKit
import Combine

final class SettingsMainView: UIView {
    
    // MARK: - Properties
    
    // MARK: - UI
    
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
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
        ])
    }
}


