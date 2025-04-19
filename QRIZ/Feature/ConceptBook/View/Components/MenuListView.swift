//
//  MenuListView.swift
//  QRIZ
//
//  Created by 김세훈 on 4/18/25.
//

import UIKit
import Combine

final class MenuListView: UIView {
    
    // MARK: - Enums
    
    private enum Attributes {
        static let chevronIcon = "chevron.right"
    }
    
    // MARK: - Properties
    
    private let tappedSubject = PassthroughSubject<ConceptItem, Never>()
    
    var tappedPublisher: AnyPublisher<ConceptItem, Never> {
        tappedSubject.eraseToAnyPublisher()
    }
    
    // MARK: - UI
    
    private let vStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 8
        return stackView
    }()
    
    // MARK: - Initialize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    func configure(with items: [ConceptItem]) {
        vStackView.arrangedSubviews.forEach {
            vStackView.removeArrangedSubview($0); $0.removeFromSuperview()
        }
        
        for item in items {
            let button = makeButton(item: item)
            vStackView.addArrangedSubview(button)
        }
    }
    
    private func makeButton(item: ConceptItem) -> UIButton {
        // title
        var attrTitle = AttributedString(item.title)
        attrTitle.font = .systemFont(ofSize: 16, weight: .bold)
        attrTitle.foregroundColor = .coolNeutral800
        
        // button config
        var config = UIButton.Configuration.plain()
        config.attributedTitle = attrTitle
        config.image = UIImage(systemName: Attributes.chevronIcon)
        config.imagePlacement = .trailing
        config.background.backgroundColor = .white
        config.baseForegroundColor = .coolNeutral800
        config.background.cornerRadius = 12
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 16,bottom: 14, trailing: 24.25)
        
        let button = UIButton(configuration: config, primaryAction: nil)
        button.contentHorizontalAlignment = .fill
        
        // shadow
        button.layer.shadowColor = UIColor.coolNeutral300.cgColor
        button.layer.shadowOpacity = 0.12
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowRadius = 10
        
        button.addAction(UIAction { [weak self] _ in
            self?.tappedSubject.send(item)
        }, for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalTo: button.widthAnchor, multiplier: 0.17).isActive = true
        return button
    }
}

// MARK: - Layout Setup

extension MenuListView {
    private func addSubviews() {
        addSubview(vStackView)
    }
    
    private func setupConstraints() {
        vStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            vStackView.topAnchor.constraint(equalTo: topAnchor),
            vStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            vStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            vStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
