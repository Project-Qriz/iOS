//
//  ExamListFilterButton.swift
//  QRIZ
//
//  Created by 이창현 on 5/12/25.
//

import UIKit
import Combine

final class ExamListFilterButton: UIView {
    
    // MARK: - Properties
    private let filterLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
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
    
    let input: PassthroughSubject<ExamListViewModel.Input, Never> = .init()
    
    // MARK: - Initializers
    init() {
        super.init(frame: .zero)
        self.backgroundColor = .white
        setLayer()
        addAction()
        addViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: ExamListFilterButton")
    }
    
    // MARK: - Methods
    func setText(filterType: ExamListFilterType) {
        filterLabel.text = filterType.rawValue
    }
    
    private func setLayer() {
        layer.cornerRadius = 8
        layer.masksToBounds = false
        layer.shadowColor = UIColor.customBlue100.cgColor
        layer.shadowOpacity = 0.7
    }
    
    private func addAction() {
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sendButtonClickedInput)))
    }
    
    @objc private func sendButtonClickedInput() {
        input.send(.filterButtonClicked)
    }
}

extension ExamListFilterButton {
    private func addViews() {
        addSubview(filterLabel)
        addSubview(chevronView)
        
        filterLabel.translatesAutoresizingMaskIntoConstraints = false
        chevronView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            filterLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
            filterLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            chevronView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
            chevronView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            chevronView.widthAnchor.constraint(equalToConstant: 9),
            chevronView.heightAnchor.constraint(equalToConstant: 4.5)
        ])
    }
}
