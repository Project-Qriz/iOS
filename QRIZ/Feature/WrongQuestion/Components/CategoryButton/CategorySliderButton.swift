//
//  CategoryChoiceButton.swift
//  QRIZ
//
//  Created by ch on 1/18/25.
//

import UIKit
import Combine

final class CategorySliderButton: UIView {
    
    // MARK: - Properties
    private let sliderImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "slider.horizontal.3")?.withRenderingMode(.alwaysTemplate))
        imageView.tintColor = .coolNeutral700
        imageView.backgroundColor = .coolNeutral100
        return imageView
    }()
    
    let input: PassthroughSubject<WrongQuestionViewModel.Input, Never> = .init()
    // MARK: - Initializer
    init() {
        super.init(frame: .zero)
        backgroundColor = .coolNeutral100
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 8
        addViews()
        addButtonAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: CategoryChoiceButton")
    }
    
    private func addButtonAction() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sendButtonClicked)))
    }
    
    @objc private func sendButtonClicked() {
        input.send(.sliderButtonClicked)
    }
}

// MARK: - Auto Layout
extension CategorySliderButton {
    private func addViews() {
        addSubview(sliderImageView)
        
        sliderImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            sliderImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
            sliderImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
            sliderImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 12),
            sliderImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12)
        ])
    }
}
