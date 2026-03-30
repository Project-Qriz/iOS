//
//  ExamListFilterButton.swift
//  QRIZ
//
//  Created by 이창현 on 5/12/25.
//

import UIKit
import DesignSystem
import Combine
import QRIZUtils

final class ExamListFilterButton: UIControl {

    // MARK: - Properties

    var tap: AnyPublisher<Void, Never> {
        tapSubject.eraseToAnyPublisher()
    }
    private let tapSubject: PassthroughSubject<Void, Never> = .init()

    // MARK: - UI
    
    private let filterLabel: UILabel = {
        let label = UILabel()
        label.text = "전체"
        label.textColor = .coolNeutral600
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .left
        return label
    }()

    private let chevronView: UIImageView = {
        let image = UIImage(systemName: "chevron.down")?.withTintColor(.coolNeutral600, renderingMode: .alwaysTemplate)
        let imageView = UIImageView(image: image)
        return imageView
    }()

    // MARK: - Initialization

    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        setupAppearance()
        setupGesture()
        addSubviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods

    func setText(filterType: ExamListFilterType) {
        filterLabel.text = filterType.rawValue
    }

    private func setupAppearance() {
        layer.cornerRadius = 8
        layer.masksToBounds = false
        layer.shadowColor = UIColor.customBlue100.cgColor
        layer.shadowOpacity = 0.7
    }

    private func setupGesture() {
        addAction(UIAction { [weak self] _ in
            self?.tapSubject.send()
        }, for: .touchUpInside)
    }
}

// MARK: - Layout Setup

extension ExamListFilterButton {
    private func addSubviews() {
        addSubview(filterLabel)
        addSubview(chevronView)
    }

    private func setupConstraints() {
        filterLabel.translatesAutoresizingMaskIntoConstraints = false
        chevronView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            filterLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            filterLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            chevronView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            chevronView.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevronView.widthAnchor.constraint(equalToConstant: 9),
            chevronView.heightAnchor.constraint(equalToConstant: 4.5)
        ])
    }
}
