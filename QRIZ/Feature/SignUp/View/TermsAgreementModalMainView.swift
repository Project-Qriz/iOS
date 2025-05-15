//
//  TermsAgreementModalMainView.swift
//  QRIZ
//
//  Created by 김세훈 on 5/13/25.
//

import UIKit

final class TermsAgreementModalMainView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let headerViewTopOffset: CGFloat = 24.0
        static let allAgreeViewTopOffset: CGFloat = 24.0
        static let itemsVStackViewTopOffset: CGFloat = 16.0
        static let footerViewTopOffset: CGFloat = 32.0
        static let horizontalMargin: CGFloat = 32.0
    }
    
    private enum Attributes {
        static let footerTitle: String = "가입하기"
    }
    
    // MARK: - Properties
    
    private let headerView = TermsAgreementHeaderView()
    private let allAgreeView = TermsAgreementAllView()
    
    private let itemsVStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16.0
        return stackView
    }()
    
    private let footerView = SignUpFooterView()
    
    // MARK: - Initialize
    
    init() {
        super.init(frame: .zero)
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
        configureItems()
        footerView.configure(buttonTitle: Attributes.footerTitle)
    }
    
    private func configureItems() {
        let itmes = ["서비스 이용약관 동의", "개인정보 처리방침 동의"]
        
        itmes.forEach { item in
            let view = TermsAgreementItemView(title: item)
            itemsVStackView.addArrangedSubview(view)
        }
    }
}

// MARK: - Layout Setup

extension TermsAgreementModalMainView {
    private func addSubviews() {
        [
            headerView,
            allAgreeView,
            itemsVStackView,
            footerView
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        allAgreeView.translatesAutoresizingMaskIntoConstraints = false
        itemsVStackView.translatesAutoresizingMaskIntoConstraints = false
        footerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: Metric.headerViewTopOffset),
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.horizontalMargin),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.horizontalMargin),
            
            allAgreeView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: Metric.allAgreeViewTopOffset),
            allAgreeView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.horizontalMargin),
            allAgreeView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.horizontalMargin),
            
            itemsVStackView.topAnchor.constraint(equalTo: allAgreeView.bottomAnchor, constant: Metric.itemsVStackViewTopOffset),
            itemsVStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.horizontalMargin),
            itemsVStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.horizontalMargin),
            
            footerView.topAnchor.constraint(equalTo: itemsVStackView.bottomAnchor, constant: Metric.footerViewTopOffset),
            footerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.horizontalMargin),
            footerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.horizontalMargin),
        ])
    }
}

