//
//  ConceptBookMainView.swift
//  QRIZ
//
//  Created by 김세훈 on 4/14/25.
//

import UIKit

final class ConceptBookMainView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let firstSubjectTopOffset: CGFloat = 24.0
        static let secondSubjectTopOffset: CGFloat = 32.0
        static let horizontalMargin: CGFloat = 18.0
        static let subjectTopOffset: CGFloat = 12.0
        static let stackViewTrailingOffset: CGFloat = -135.0
    }
    
    private enum Attributes {
        static let firstSubjectText = "1과목"
        static let secondSubjectText = "2과목"
    }
    
    // MARK: - UI
    
    private let firstSubject: UILabel = {
        let label = UILabel()
        label.text = Attributes.firstSubjectText
        label.textColor = .coolNeutral800
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    private let dataModelingSubjectCard = SubjectCardView(image: .understandingDataModeling, title: "데이터 모델링의 이해", itemCount: 5)
    private let dataModelAndSQLSubjectCard = SubjectCardView(image: .dataModelAndSQL, title: "데이터 모델과 SQL", itemCount: 5)
    
    private lazy var firstSubjectCardsHStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [dataModelingSubjectCard, dataModelAndSQLSubjectCard])
        stackView.alignment = .top
        stackView.distribution = .fillEqually
        stackView.spacing = 12.0
        return stackView
    }()
    
    private let secondSubject: UILabel = {
        let label = UILabel()
        label.text = Attributes.secondSubjectText
        label.textColor = .coolNeutral800
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    private let sqlBasicsSubjectCard = SubjectCardView(image: .sqlBasics, title: "SQL 기본", itemCount: 8)
    private let sqlAdvancedSubjectCard = SubjectCardView(image: .sqlAdvanced, title: "SQL 활용", itemCount: 8)
    private let managementStatementsSubjectCard = SubjectCardView(image: .managementStatements, title: "관리 구문", itemCount: 4)
    
    private lazy var secondSubjectCardsStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                sqlBasicsSubjectCard,
                sqlAdvancedSubjectCard,
                managementStatementsSubjectCard
            ]
        )
        stackView.axis = .horizontal
        stackView.spacing = 12.0
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
        self.backgroundColor = .white
    }
}

// MARK: - Layout Setup

extension ConceptBookMainView {
    private func addSubviews() {
        [
            firstSubject,
            firstSubjectCardsHStackView,
            secondSubject,
            secondSubjectCardsStackView
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        firstSubject.translatesAutoresizingMaskIntoConstraints = false
        firstSubjectCardsHStackView.translatesAutoresizingMaskIntoConstraints = false
        secondSubject.translatesAutoresizingMaskIntoConstraints = false
        secondSubjectCardsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            firstSubject.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: Metric.firstSubjectTopOffset),
            firstSubject.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.horizontalMargin),
            
            firstSubjectCardsHStackView.topAnchor.constraint(equalTo: firstSubject.bottomAnchor, constant: Metric.subjectTopOffset),
            firstSubjectCardsHStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.horizontalMargin),
            firstSubjectCardsHStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Metric.stackViewTrailingOffset),
            
            secondSubject.topAnchor.constraint(equalTo: firstSubjectCardsHStackView.bottomAnchor, constant: Metric.secondSubjectTopOffset),
            secondSubject.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.horizontalMargin),
            
            secondSubjectCardsStackView.topAnchor.constraint(equalTo: secondSubject.bottomAnchor, constant: Metric.subjectTopOffset),
            secondSubjectCardsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.horizontalMargin),
            secondSubjectCardsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.horizontalMargin)
        ])
    }
}
