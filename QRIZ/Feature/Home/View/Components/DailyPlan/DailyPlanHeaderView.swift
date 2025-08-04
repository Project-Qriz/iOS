//
//  DailyPlanHeaderView.swift
//  QRIZ
//
//  Created by 김세훈 on 6/26/25.
//

import UIKit
import Combine

final class DailyPlanHeaderView: UICollectionViewCell {
    
    // MARK: - Enums
    
    private enum Metric {
        static let buttonSize: CGFloat = 24.0
        static let lockImageSize: CGFloat = 20.0
        static let noticeLineHeight: CGFloat = 1.0
    }
    
    private enum Attributes {
        static let notice = "프리뷰 시험을 보면 열려요!"
        static let chevron: String = "chevron.down"
        static let titleText: String = "오늘의 공부"
    }
    
    // MARK: - Properties
    
    private let resetButtonTapSubject = PassthroughSubject<Void, Never>()
    private let dayButtonTapSubject = PassthroughSubject<Void, Never>()
    var cancellables = Set<AnyCancellable>()
    
    var resetButtonTapPublisher: AnyPublisher<Void, Never> {
        resetButtonTapSubject.eraseToAnyPublisher()
    }
    
    var dayButtonTapPublisher: AnyPublisher<Void, Never> {
        dayButtonTapSubject.eraseToAnyPublisher()
    }
    
    // MARK: - UI
    
    private let noticeLabel: UILabel = {
        let label = UILabel()
        label.text = Attributes.notice
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .coolNeutral500
        return label
    }()
    
    private let noticeLine: UIView = {
        let view = UIView()
        view.backgroundColor = .coolNeutral200
        return view
    }()
    
    private lazy var noticeHStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [noticeLabel, noticeLine])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()
    
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
    
    private lazy var resetButton: UIButton = {
        let button = UIButton()
        button.setImage(.homeReset, for: .normal)
        button.tintColor = .coolNeutral800
        
        button.addAction(UIAction { [weak self] _ in
            self?.resetButtonTapSubject.send()
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var dayButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.contentInsets = .zero
        config.imagePadding  = 4
        config.titleAlignment = .leading
        config.imagePlacement = .trailing
        
        var title = AttributedString("Day1")
        title.font = .systemFont(ofSize: 16, weight: .medium)
        title.foregroundColor = .coolNeutral600
        config.attributedTitle = title
        
        let button = UIButton(configuration: config)
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .regular)
        let chevron = UIImage(systemName: Attributes.chevron, withConfiguration: symbolConfig)?
            .withRenderingMode(.alwaysTemplate)
        
        button.setImage(chevron, for: .normal)
        button.tintColor = .coolNeutral600
        button.contentHorizontalAlignment = .leading
        
        button.addAction(UIAction { [weak self] _ in
            self?.dayButtonTapSubject.send()
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var rootVStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [noticeHStackView, titleHStackView, dayButton])
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.setCustomSpacing(20, after: noticeHStackView)
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
        backgroundColor = .customBlue50
    }
    
    func configure(day: Int, locked: Bool) {
        dayButton.configuration?.title = "Day\(day)"
        
        lockImageView.isHidden = !locked
        noticeHStackView.isHidden = !locked
        resetButton.isHidden = locked
        dayButton.isHidden = locked
    }
}

// MARK: - Layout Setup

extension DailyPlanHeaderView {
    private func addSubviews() {
        [
            rootVStackView,
            resetButton,
        ].forEach(contentView.addSubview(_:))
    }
    
    private func setupConstraints() {
        rootVStackView.translatesAutoresizingMaskIntoConstraints = false
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            rootVStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            rootVStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            rootVStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            rootVStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            noticeLine.heightAnchor.constraint(equalToConstant: Metric.noticeLineHeight),
            
            lockImageView.heightAnchor.constraint(equalToConstant: Metric.lockImageSize),
            lockImageView.widthAnchor.constraint(equalToConstant: Metric.lockImageSize),
            
            resetButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            resetButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            resetButton.widthAnchor.constraint(equalToConstant: Metric.buttonSize),
            resetButton.heightAnchor.constraint(equalToConstant: Metric.buttonSize),
        ])
    }
}
