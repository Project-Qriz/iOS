//
//  TestPageIndicatorLabel.swift
//  QRIZ
//
//  Created by ch on 12/22/24.
//

import UIKit

final class TestPageIndicatorLabel: UILabel {
    
    // MARK: - Properties
    private var currentPageLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = .boldSystemFont(ofSize: 16)
        label.textAlignment = .right
        label.numberOfLines = 1
        label.textColor = .coolNeutral800
        return label
    }()
    
    private var totalPageLabel: UILabel = {
        let label = UILabel()
        label.text = "/0"
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.textColor = .coolNeutral500
        return label
    }()
    
    // MARK: - Initializers
    init() {
        super.init(frame: .zero)
        addViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: TestPageindicatorLabel")
    }

    // MARK: - Methods
    func setPages(curPage: Int, totalPage: Int) {
        self.currentPageLabel.text = String(format: "%02d ", curPage)
        self.totalPageLabel.text = String(format: "/ %02d", totalPage)
    }
}

// MARK: - AutoLayout
extension TestPageIndicatorLabel {
    private func addViews() {
        self.addSubview(currentPageLabel)
        self.addSubview(totalPageLabel)
        
        currentPageLabel.translatesAutoresizingMaskIntoConstraints = false
        totalPageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            currentPageLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            totalPageLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            currentPageLabel.heightAnchor.constraint(equalToConstant: 20),
            totalPageLabel.heightAnchor.constraint(equalToConstant: 20),
            currentPageLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            totalPageLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            currentPageLabel.trailingAnchor.constraint(equalTo: self.centerXAnchor, constant: -5),
            totalPageLabel.leadingAnchor.constraint(equalTo: self.centerXAnchor)
        ])
    }
}
