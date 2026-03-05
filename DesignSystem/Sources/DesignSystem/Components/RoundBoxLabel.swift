//
//  RoundBoxLabel.swift
//  DesignSystem
//
//  Created by 김세훈 on 4/29/25.
//

import UIKit

public final class RoundBoxLabel: UIView {

    // MARK: - UI

    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 24)
        return label
    }()

    // MARK: - Initialization

    public init(text: String, width: CGFloat, height: CGFloat) {
        super.init(frame: .zero)
        setupUI()
        setupLayout(width: width, height: height)
        setText(text)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods

    private func setupUI() {
        backgroundColor = .customBlue500
        layer.cornerRadius = 8
        addSubview(label)
    }

    private func setupLayout(width: CGFloat, height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            widthAnchor.constraint(equalToConstant: width),
            heightAnchor.constraint(equalToConstant: height)
        ])
    }

    public func setText(_ text: String) {
        label.text = text
    }
}
