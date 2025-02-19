//
//  TestNavigatorButton.swift
//  QRIZ
//
//  Created by ch on 2/16/25.
//

import UIKit

final class TestNavigatorButton: UIView {
    
    private let testStatusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    private let testTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textAlignment = .left
        label.textColor = .coolNeutral700
        label.numberOfLines = 1
        return label
    }()
    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .left
        label.textColor = .coolNeutral500
        label.numberOfLines = 1
        return label
    }()
    private let testProgressView: UIView = {
        let view = UIView(frame: .zero)
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()
    private let chevronImageView: UIImageView = {
        let image = UIImage(systemName: "chevron.right")?.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.tintColor = .coolNeutral800
        imageView.backgroundColor = .white
        return imageView
    }()
    private let retryBadge: UILabel = {
        let label = UILabel()
        label.backgroundColor = .customRed500.withAlphaComponent(0.14)
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .customRed500
        label.textAlignment = .center
        label.numberOfLines = 1
        label.text = "점수 미달"
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        return label
    }()
    
    // MARK: - Intializer
    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        setLayer()
        addViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: TestNavigatorButton")
    }
    
    // MARK: - Methods
    func setDailyUI(state: DailyTestState, type: DailyLearnType, score: Int?) {
        updateBgColor(state: state)
        updateTestStatusLabel(state: state)
        updateTestTitleLabel(type: type)
        updateScoreLabel(score: score)
        updateTestProgressView(score: score)
        updateRetryBadge(state: state)
    }
    
    private func updateBgColor(state: DailyTestState) {
        backgroundColor = (state == .unavailable ? .coolNeutral100 : .white)
    }
    
    private func updateTestStatusLabel(state: DailyTestState) {
        switch state {
        case .unavailable:
            testStatusLabel.text = "학습 불가"
            testStatusLabel.textColor = .customRed500
        case .zeroAttempt:
            testStatusLabel.text = "학습 전"
            testStatusLabel.textColor = .customBlue700
        default:
            testStatusLabel.text = "학습 완료"
            testStatusLabel.textColor = .customBlue400
        }
    }
    
    private func updateTestTitleLabel(type: DailyLearnType) {
        switch type {
        case .daily:
            testTitleLabel.text = "데일리 테스트"
        case .weekly:
            testTitleLabel.text = "주간 복습 테스트"
        case .monthly:
            testTitleLabel.text = "종합 복습 테스트"
        }
    }
    
    private func updateScoreLabel(score: Int?) {
        let scoreText = score.map { "\($0)" } ?? ""
        scoreLabel.text = "총 점수: \(scoreText)점"
    }
    
    private func updateTestProgressView(score: Int?) {
        if score == nil {
            testProgressView.backgroundColor = .coolNeutral200
        } else {
            testProgressView.backgroundColor = .customBlue500
        }
    }
    
    private func updateRetryBadge(state: DailyTestState) {
        if state == .retestRequired {
            retryBadge.isHidden = false
        } else {
            retryBadge.isHidden = true
        }
    }
    
    private func setLayer() {
        layer.cornerRadius = 12
        layer.masksToBounds = true
        layer.borderColor = UIColor.coolNeutral100.cgColor
        layer.borderWidth = 1
    }
}

// MARK: - Auto Layout
extension TestNavigatorButton {
    private func addViews() {
        addSubview(testStatusLabel)
        addSubview(testTitleLabel)
        addSubview(scoreLabel)
        addSubview(testProgressView)
        addSubview(chevronImageView)
        addSubview(retryBadge)
        
        testStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        testTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        testProgressView.translatesAutoresizingMaskIntoConstraints = false
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        retryBadge.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            testStatusLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            testStatusLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            
            testTitleLabel.topAnchor.constraint(equalTo: testStatusLabel.bottomAnchor, constant: 10),
            testTitleLabel.leadingAnchor.constraint(equalTo: testStatusLabel.leadingAnchor),
            
            testProgressView.topAnchor.constraint(equalTo: testTitleLabel.bottomAnchor, constant: 10),
            testProgressView.leadingAnchor.constraint(equalTo: testStatusLabel.leadingAnchor),
            testProgressView.heightAnchor.constraint(equalToConstant: 8),
            testProgressView.trailingAnchor.constraint(equalTo: self.centerXAnchor, constant: 80),
            
            scoreLabel.topAnchor.constraint(equalTo: testProgressView.bottomAnchor, constant: 6),
            scoreLabel.leadingAnchor.constraint(equalTo: testStatusLabel.leadingAnchor),
            
            retryBadge.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 10),
            retryBadge.leadingAnchor.constraint(equalTo: testStatusLabel.leadingAnchor),
            retryBadge.widthAnchor.constraint(equalToConstant: 61),
            retryBadge.heightAnchor.constraint(equalToConstant: 26),
            
            chevronImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            chevronImageView.widthAnchor.constraint(equalToConstant: 18),
            chevronImageView.heightAnchor.constraint(equalToConstant: 28)
        ])
    }
}
