//
//  SingleSupplementConceptView.swift
//  QRIZ
//
//  Created by ch on 12/31/24.
//

import UIKit

final class SingleSupplementConceptView: UIView {
    
    let conceptLabel: UILabel = {
        let label = UILabel()
        label.text = "불러오는 중"
        label.font = .boldSystemFont(ofSize: 22)
        label.numberOfLines = 1
        label.textColor = .coolNeutral700
        label.textAlignment = .left
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        self.layer.cornerRadius = 12
        self.backgroundColor = .white
        addViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func setConceptLabelText(topic: String) {
        self.conceptLabel.text = topic
    }
    
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
