//
//  WeeklyConceptCell.swift
//  QRIZ
//
//  Created by 김세훈 on 7/20/25.
//

import UIKit
import Combine

final class WeeklyConceptCell: UICollectionViewCell {
    
    // MARK: - Enums
    
    private enum Metric {
        static let buttonViewTop: CGFloat = 16.0
        static let lockImageSize: CGFloat = 20.0
    }
    
    private enum Attributes {
        static let titleText = "주간 추천 개념"
    }
    
    // MARK: - Properties
    
    private let conceptTappedSubject = PassthroughSubject<Int, Never>()
    var cancellables = Set<AnyCancellable>()
    
    var conceptTappedPublisher: AnyPublisher<Int, Never> {
        conceptTappedSubject.eraseToAnyPublisher()
    }
    
    // MARK: - UI
    
    private let lockImageView: UIImageView = {
        let imageView = UIImageView(image: .lock)
        imageView.tintColor = .coolNeutral800
        imageView.isHidden = true
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Attributes.titleText
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .coolNeutral800
        return label
    }()
    
    private lazy var titleHStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [lockImageView, titleLabel])
        view.axis = .horizontal
        view.spacing = 4
        return view
    }()
    
    private let firstButton = TestNavigatorButton()
    private let secondButton = TestNavigatorButton()
    
    private lazy var buttonVStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [firstButton, secondButton])
        view.axis = .vertical
        view.spacing = 8
        view.distribution = .fillEqually
        return view
    }()
    
    private let blurOverlay: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .light)
        let ve = UIVisualEffectView(effect: blur)
        ve.alpha = 0.7
        ve.layer.cornerRadius = 12
        ve.clipsToBounds = true
        ve.isHidden = true
        return ve
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
        backgroundColor = .customBlue50
    }
    
    func configure(kind: RecommendationKind, concepts: [WeeklyConcept]) {
        if kind == .weeklyCustom { titleLabel.text = kind.rawValue }
        let locked = (kind == .previewIncomplete || kind == .unknown)
        lockImageView.isHidden = !locked
        
        let dataToShow: [WeeklyConcept] = {
            if locked {
                return [
                    .init(id: -1, title: "데이터 모델의 이해", subjectCount: 1, importance: .high),
                    .init(id: -1, title: "SELECT 문", subjectCount: 1, importance: .low)
                ]
            } else {
                return concepts
            }
        }()
        
        let buttons = [firstButton, secondButton]
        
        for (index, concept) in dataToShow.enumerated() {
            guard index < buttons.count else { break }
            let button = buttons[index]

            button.setWeeklyConceptUI(concept: concept, locked: locked)
            button.tapGestureEndedPublisher()
                .sink { [weak self] _ in
                    self?.conceptTappedSubject.send(index)
                }
                .store(in: &cancellables)
        }
        
        if dataToShow.count < buttons.count {
            for index in dataToShow.count..<buttons.count {
                buttons[index].isHidden = true
            }
        }
        
        blurOverlay.isHidden = !locked
    }
}

// MARK: - Layout Setup

extension WeeklyConceptCell {
    private func addSubviews() {
        [
            titleHStackView,
            buttonVStackView
        ].forEach(contentView.addSubview(_:))
        buttonVStackView.addSubview(blurOverlay)
    }
    
    private func setupConstraints() {
        titleHStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonVStackView.translatesAutoresizingMaskIntoConstraints = false
        blurOverlay.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleHStackView.topAnchor.constraint(
                equalTo: contentView.topAnchor
            ),
            titleHStackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),
            
            lockImageView.heightAnchor.constraint(
                equalToConstant: Metric.lockImageSize
            ),
            lockImageView.widthAnchor.constraint(
                equalToConstant: Metric.lockImageSize
            ),
            
            buttonVStackView.topAnchor.constraint(
                equalTo: titleHStackView.bottomAnchor,
                constant: Metric.buttonViewTop
            ),
            buttonVStackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),
            buttonVStackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor
            ),
            buttonVStackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor
            ),
            
            blurOverlay.topAnchor.constraint(
                equalTo: buttonVStackView.topAnchor
            ),
            blurOverlay.leadingAnchor.constraint(
                equalTo: buttonVStackView.leadingAnchor
            ),
            blurOverlay.trailingAnchor.constraint(
                equalTo: buttonVStackView.trailingAnchor
            ),
            blurOverlay.bottomAnchor.constraint(
                equalTo: buttonVStackView.bottomAnchor
            )
        ])
    }
}

