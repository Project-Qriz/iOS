//
//  TestPageIndicatorLabel.swift
//  ExamKit
//

import UIKit
import DesignSystem

public final class TestPageIndicatorLabel: UIView {

    // MARK: - Properties

    private let currentPageLabel: UILabel = {
        let label = UILabel()
        label.text = String(format: "%02d ", 0)
        label.font = .boldSystemFont(ofSize: 16)
        label.textAlignment = .right
        label.textColor = .coolNeutral800
        return label
    }()

    private let totalPageLabel: UILabel = {
        let label = UILabel()
        label.text = String(format: "/ %02d", 0)
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .left
        label.textColor = .coolNeutral500
        return label
    }()

    // MARK: - Initialization

    public init() {
        super.init(frame: .zero)
        addSubviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: TestPageIndicatorLabel")
    }

    // MARK: - Methods

    public func setCurrentPage(_ page: Int) {
        currentPageLabel.text = String(format: "%02d ", page)
    }

    public func setTotalPage(_ total: Int) {
        totalPageLabel.text = String(format: "/ %02d", total)
    }
}

// MARK: - Layout

extension TestPageIndicatorLabel {
    private func addSubviews() {
        addSubview(currentPageLabel)
        addSubview(totalPageLabel)
    }

    private func setupConstraints() {
        currentPageLabel.translatesAutoresizingMaskIntoConstraints = false
        totalPageLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            currentPageLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            currentPageLabel.heightAnchor.constraint(equalToConstant: 20),
            currentPageLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            currentPageLabel.trailingAnchor.constraint(equalTo: centerXAnchor, constant: -5),

            totalPageLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            totalPageLabel.heightAnchor.constraint(equalToConstant: 20),
            totalPageLabel.leadingAnchor.constraint(equalTo: centerXAnchor),
            totalPageLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
