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
    
    private let optionTapSubject = PassthroughSubject<SettingsOption, Never>()
    
    var optionTapPublisher: AnyPublisher<SettingsOption, Never> {
        optionTapSubject.eraseToAnyPublisher()
    }
    
    // MARK: - UI
    
    let profileHeaderView = ProfileHeaderView()
    
    private lazy var optionsVStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: makeOptionViews())
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
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
    
    private func makeOptionViews() -> [SettingsOptionView] {
        return SettingsOption.allCases.map { type in
            let view = SettingsOptionView(title: type.rawValue)
            view.tapGestureEndedPublisher()
                .sink { [weak self] _ in
                    self?.optionTapSubject.send(type)
                }
                .store(in: &view.cancellables)
            return view
        }
    }
}

// MARK: - Layout Setup

extension SettingsMainView {
    private func addSubviews() {
        [
            profileHeaderView,
            optionsVStackView
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        profileHeaderView.translatesAutoresizingMaskIntoConstraints = false
        optionsVStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
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
            
            optionsVStackView.topAnchor.constraint(
                equalTo: profileHeaderView.bottomAnchor,
                constant: Metric.headerViewTopOffset
            ),
            optionsVStackView.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Metric.horizontalSpacing
            ),
            optionsVStackView.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -Metric.horizontalSpacing
            ),
        ])
    }
}


