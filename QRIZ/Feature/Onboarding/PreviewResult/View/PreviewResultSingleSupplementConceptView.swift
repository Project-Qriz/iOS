//
//  SingleSupplementConceptView.swift
//  QRIZ
//
//  Created by ch on 12/31/24.
//

import UIKit

final class PreviewResultSingleSupplementConceptView: UIView {
    
    // MARK: - Properties
    let conceptLabel: UILabel = {
        let label = UILabel()
        label.text = "불러오는 중"
        label.font = .boldSystemFont(ofSize: 22)
        label.numberOfLines = 1
        label.textColor = .coolNeutral700
        label.textAlignment = .left
        return label
    }()
    
    // MARK: - Initializers
    init() {
        super.init(frame: .zero)
        self.layer.cornerRadius = 12
        self.backgroundColor = .customBlue50
        addViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Methods
    func setConceptLabelText(topic: String) {
        self.conceptLabel.text = topic
    }
}

// MARK: - Auto Layout
extension PreviewResultSingleSupplementConceptView {
    private func addViews() {
        self.addSubview(conceptLabel)
        conceptLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            conceptLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            conceptLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24),
            conceptLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24)
        ])
    }
}
