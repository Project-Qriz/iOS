//
//  DailyLearnView.swift
//  QRIZ
//
//  Created by QRIZ on 3/27/25.
//

import UIKit
import DesignSystem
import QRIZUtils

final class DailyLearnView: UIView {
    
    // MARK: - Enums

    private enum Metric {
        static let horizontalInset: CGFloat = 18
        static let sectionTitleTopOffset: CGFloat = 25
        static let collectionViewTopSpacing: CGFloat = 17
        static let relatedTestTopSpacing: CGFloat = 32
        static let subtextTopSpacing: CGFloat = 19
        static let navigatorTopSpacing: CGFloat = 18
        static let navigatorBottomInset: CGFloat = 100
        static let navigatorHeightDefault: CGFloat = 116
        static let navigatorHeightRetest: CGFloat = 153
    }
    
    // MARK: - Properties
    
    var onTestNavigatorTap: (() -> Void)?

    private var collectionViewHeightConstraint: NSLayoutConstraint?
    private var testNavigatorHeightConstraint: NSLayoutConstraint?
    
    // MARK: - UI
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .customBlue50
        return scrollView
    }()
    
    private let scrollInnerView: UIView = .init()
    
    private let studyContentTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .coolNeutral800
        label.textAlignment = .left
        return label
    }()

    private(set) var studyCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .customBlue50
        collectionView.layer.masksToBounds = false
        collectionView.register(StudyContentCell.self, forCellWithReuseIdentifier: StudyContentCell.identifier)
        return collectionView
    }()
    
    private let relatedTestTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .coolNeutral800
        label.textAlignment = .left
        label.text = "관련된 테스트"
        return label
    }()
    
    private let testSubtextLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .coolNeutral500
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    private let testNavigator: TestNavigatorButton = .init()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .customBlue50
        testNavigator.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTestNavigatorTap)))
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    func configure(state: DailyTestState, type: DailyLearnType, score: Double?) {
        setContentTitle(type: type)
        setTestSubtextLabel(state: state)
        testNavigator.setDailyUI(state: state, type: type, score: score)
        setNavigatorButtonHeight(state: state)
    }
    
    func reloadConcepts() {
        studyCollectionView.reloadData()
        studyCollectionView.layoutIfNeeded()
        collectionViewHeightConstraint?.isActive = false
        collectionViewHeightConstraint = studyCollectionView.heightAnchor.constraint(
            equalToConstant: studyCollectionView.contentSize.height
        )
        collectionViewHeightConstraint?.isActive = true
    }
    
    @objc private func handleTestNavigatorTap() {
        onTestNavigatorTap?()
    }
    
    private func setContentTitle(type: DailyLearnType) {
        switch type {
        case .daily:
            studyContentTitleLabel.text = "오늘 공부할 내용"
        case .weekly:
            studyContentTitleLabel.text = "주간 복습 내용"
        case .monthly:
            studyContentTitleLabel.text = "종합 복습 내용"
        }
    }
    
    private func setTestSubtextLabel(state: DailyTestState) {
        switch state {
        case .unavailable:
            testSubtextLabel.text = "이전 테스트를 학습 완료했는지 확인해주세요!"
        case .zeroAttempt:
            testSubtextLabel.text = "아래의 테스트를 학습 완료해야만 다음 데일리 테스트를 진행할 수 있습니다!"
        case .passed, .failed:
            testSubtextLabel.text = "학습완료. 수고하셨어요!"
        case .retestRequired:
            testSubtextLabel.text = "점수 미달인 경우 재시험을 볼 수 있습니다."
        }
    }
    
    private func setNavigatorButtonHeight(state: DailyTestState) {
        testNavigatorHeightConstraint?.constant = state == .retestRequired
            ? Metric.navigatorHeightRetest
            : Metric.navigatorHeightDefault
    }
}

// MARK: - Layout Setup

extension DailyLearnView {
    private func addSubviews() {
        addSubview(scrollView)
        scrollView.addSubview(scrollInnerView)
        [
            studyContentTitleLabel,
            studyCollectionView,
            relatedTestTitleLabel,
            testSubtextLabel,
            testNavigator
        ].forEach(scrollInnerView.addSubview(_:))
    }
    
    private func setupConstraints() {
        [
            scrollView,
            scrollInnerView,
            studyContentTitleLabel,
            studyCollectionView,
            relatedTestTitleLabel,
            testSubtextLabel,
            testNavigator
        ].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            scrollInnerView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            scrollInnerView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            scrollInnerView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            scrollInnerView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            scrollInnerView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            studyContentTitleLabel.topAnchor.constraint(equalTo: scrollInnerView.topAnchor, constant: Metric.sectionTitleTopOffset),
            studyContentTitleLabel.leadingAnchor.constraint(equalTo: scrollInnerView.leadingAnchor, constant: Metric.horizontalInset),
            
            studyCollectionView.topAnchor.constraint(equalTo: studyContentTitleLabel.bottomAnchor, constant: Metric.collectionViewTopSpacing),
            studyCollectionView.leadingAnchor.constraint(equalTo: scrollInnerView.leadingAnchor, constant: Metric.horizontalInset),
            studyCollectionView.trailingAnchor.constraint(equalTo: scrollInnerView.trailingAnchor, constant: -Metric.horizontalInset),
            
            relatedTestTitleLabel.topAnchor.constraint(equalTo: studyCollectionView.bottomAnchor, constant: Metric.relatedTestTopSpacing),
            relatedTestTitleLabel.leadingAnchor.constraint(equalTo: scrollInnerView.leadingAnchor, constant: Metric.horizontalInset),
            relatedTestTitleLabel.trailingAnchor.constraint(equalTo: scrollInnerView.trailingAnchor, constant: -Metric.horizontalInset),
            
            testSubtextLabel.topAnchor.constraint(equalTo: relatedTestTitleLabel.bottomAnchor, constant: Metric.subtextTopSpacing),
            testSubtextLabel.leadingAnchor.constraint(equalTo: scrollInnerView.leadingAnchor, constant: Metric.horizontalInset),
            testSubtextLabel.trailingAnchor.constraint(equalTo: scrollInnerView.trailingAnchor, constant: -Metric.horizontalInset),
            
            testNavigator.topAnchor.constraint(equalTo: testSubtextLabel.bottomAnchor, constant: Metric.navigatorTopSpacing),
            testNavigator.leadingAnchor.constraint(equalTo: scrollInnerView.leadingAnchor, constant: Metric.horizontalInset),
            testNavigator.trailingAnchor.constraint(equalTo: scrollInnerView.trailingAnchor, constant: -Metric.horizontalInset),
            testNavigator.bottomAnchor.constraint(equalTo: scrollInnerView.bottomAnchor, constant: -Metric.navigatorBottomInset),
        ])

        testNavigatorHeightConstraint = testNavigator.heightAnchor.constraint(equalToConstant: Metric.navigatorHeightDefault)
        testNavigatorHeightConstraint?.isActive = true
    }
}
