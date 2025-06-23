//
//  DeleteAccountMainView.swift
//  QRIZ
//
//  Created by 김세훈 on 6/16/25.
//

import UIKit
import Combine

final class DeleteAccountMainView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let separatorHeight: CGFloat = 1.0
        static let titleTopOffset: CGFloat = 40.0
        static let horizontalSpacing: CGFloat = 18.0
        static let verticalSpacing: CGFloat = 20.0
        static let bulletLabel2TopOffset: CGFloat = 8.0
        static let delteButtonTopOffset: CGFloat = 14.0
        static let deleteButtonHeightRatio: CGFloat = 0.117
    }
    
    private enum Attributes {
        static let titleText: String = "회원 탈퇴 시 아래 내용을 확인해 주세요."
        static let bullet1Text: String = "•  회원 탈퇴 시 계정 정보는 모두 삭제됩니다."
        static let bullet2Text: String = "•  진행 중인 ‘오늘의 공부’를 포함해, 모든 데이터가 삭\n    제되며 복구할 수 없습니다."
        static let questionText: String = "QRIZ 회원 탈퇴를 하시겠습니까?"
        static let deleteButtonTitle: String = "회원 탈퇴"
    }
    
    // MARK: - Properties
    
    private let deleteTapSubject = PassthroughSubject<Void, Never>()
    
    var deleteTapPublisher: AnyPublisher<Void, Never> {
        deleteTapSubject.eraseToAnyPublisher()
    }
    
    // MARK: - UI
    
    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .coolNeutral100
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Attributes.titleText
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .coolNeutral800
        return label
    }()
    
    private let infoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.coolNeutral100.cgColor
        view.layer.cornerRadius = 8.0
        view.applyQRIZShadow(radius: 8.0)
        return view
    }()
    
    private let bulletLabel1: UILabel = {
        let label = UILabel()
        label.text = Attributes.bullet1Text
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .coolNeutral500
        return label
    }()
    
    private let bulletLabel2: UILabel = {
        let label = UILabel()
        label.text = Attributes.bullet2Text
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .coolNeutral500
        label.numberOfLines = 2
        return label
    }()
    
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.text = Attributes.questionText
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .coolNeutral500
        return label
    }()
    
    private lazy var deleteButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = Attributes.deleteButtonTitle
        config.baseBackgroundColor = .customBlue500
        config.baseForegroundColor = .white
        config.cornerStyle = .medium
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var attrs = incoming
            attrs.font = .systemFont(ofSize: 16, weight: .medium)
            return attrs
        }
        let button = UIButton(configuration: config)
        button.addAction(UIAction { [weak self] _ in
            self?.deleteTapSubject.send()
        }, for: .touchUpInside)
        return button
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
        backgroundColor = .white
    }
}

// MARK: - Layout Setup

extension DeleteAccountMainView {
    private func addSubviews() {
        [
            separator,
            titleLabel,
            infoContainerView,
            questionLabel,
            deleteButton
        ].forEach(addSubview(_:))
        
        [
            bulletLabel1,
            bulletLabel2
        ].forEach(infoContainerView.addSubview(_:))
    }
    
    private func setupConstraints() {
        separator.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        infoContainerView.translatesAutoresizingMaskIntoConstraints = false
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        bulletLabel1.translatesAutoresizingMaskIntoConstraints = false
        bulletLabel2.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            separator.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: Metric.separatorHeight),
            
            titleLabel.topAnchor.constraint(
                equalTo: safeAreaLayoutGuide.topAnchor,
                constant: Metric.titleTopOffset
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Metric.horizontalSpacing
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -Metric.horizontalSpacing
            ),
            
            infoContainerView.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: Metric.verticalSpacing
            ),
            infoContainerView.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Metric.horizontalSpacing
            ),
            infoContainerView.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: Metric.horizontalSpacing
            ),
            
            bulletLabel1.topAnchor.constraint(
                equalTo: infoContainerView.topAnchor,
                constant: Metric.verticalSpacing
            ),
            bulletLabel1.leadingAnchor.constraint(
                equalTo: infoContainerView.leadingAnchor,
                constant: Metric.horizontalSpacing
            ),
            bulletLabel1.trailingAnchor.constraint(
                equalTo: infoContainerView.trailingAnchor,
                constant: -Metric.horizontalSpacing
            ),
            
            bulletLabel2.topAnchor.constraint(
                equalTo: bulletLabel1.bottomAnchor,
                constant: Metric.bulletLabel2TopOffset
            ),
            bulletLabel2.leadingAnchor.constraint(
                equalTo: infoContainerView.leadingAnchor,
                constant: Metric.horizontalSpacing
            ),
            bulletLabel2.trailingAnchor.constraint(
                equalTo: infoContainerView.trailingAnchor,
                constant: -Metric.horizontalSpacing
            ),
            bulletLabel2.bottomAnchor.constraint(
                equalTo: infoContainerView.bottomAnchor,
                constant: -Metric.verticalSpacing
            ),
            
            questionLabel.topAnchor.constraint(
                equalTo: infoContainerView.bottomAnchor,
                constant: Metric.verticalSpacing
            ),
            questionLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Metric.horizontalSpacing
            ),
            questionLabel.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -Metric.horizontalSpacing
            ),
            
            deleteButton.topAnchor.constraint(
                equalTo: questionLabel.bottomAnchor,
                constant: Metric.delteButtonTopOffset
            ),
            deleteButton.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Metric.horizontalSpacing
            ),
            deleteButton.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -Metric.horizontalSpacing
            ),
            deleteButton.heightAnchor.constraint(
                equalTo: deleteButton.widthAnchor,
                multiplier: Metric.deleteButtonHeightRatio
            )
        ])
    }
}


