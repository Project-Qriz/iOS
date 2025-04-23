//
//  ConceptBookMainView.swift
//  QRIZ
//
//  Created by 김세훈 on 4/14/25.
//

import UIKit
import Combine

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
    
    // MARK: - Properties
    
    private let chapterTappedSubject = PassthroughSubject<Chapter, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    var chapterTappedPublisher: AnyPublisher<Chapter, Never> {
        chapterTappedSubject.eraseToAnyPublisher()
    }
    
    // MARK: - UI
    
    private let firstSubjectLabel: UILabel = {
        let label = UILabel()
        label.text = Attributes.firstSubjectText
        label.textColor = .coolNeutral800
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    private let firstSubjectCardsHStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.distribution = .fillEqually
        stackView.spacing = 12.0
        return stackView
    }()
    
    private let secondSubjectLabel: UILabel = {
        let label = UILabel()
        label.text = Attributes.secondSubjectText
        label.textColor = .coolNeutral800
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    private let secondSubjectCardsHStackView: UIStackView = {
        let stackView = UIStackView()
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
    
    func configure(with subjects: [Subject]) {
        guard subjects.count >= 2 else { return }
        configureSection(stackView: firstSubjectCardsHStackView, with: subjects[0].chapters)
        configureSection(stackView: secondSubjectCardsHStackView, with: subjects[1].chapters)
        
    }
    
    private func configureSection(stackView: UIStackView, with chapters: [Chapter]) {
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        chapters.forEach { chapter in
            let card = SubjectCardView(
                image: UIImage(named: chapter.assetName),
                title: chapter.cardTitle,
                itemCount: chapter.cardItemCount
            )
            card.tapGestureEndedPublisher()
                .sink { [weak self] in self?.chapterTappedSubject.send(chapter) }
                .store(in: &cancellables)
            stackView.addArrangedSubview(card)
        }
    }
}

// MARK: - Layout Setup

extension ConceptBookMainView {
    private func addSubviews() {
        [
            firstSubjectLabel,
            firstSubjectCardsHStackView,
            secondSubjectLabel,
            secondSubjectCardsHStackView
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        firstSubjectLabel.translatesAutoresizingMaskIntoConstraints = false
        firstSubjectCardsHStackView.translatesAutoresizingMaskIntoConstraints = false
        secondSubjectLabel.translatesAutoresizingMaskIntoConstraints = false
        secondSubjectCardsHStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            firstSubjectLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: Metric.firstSubjectTopOffset),
            firstSubjectLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.horizontalMargin),
            
            firstSubjectCardsHStackView.topAnchor.constraint(equalTo: firstSubjectLabel.bottomAnchor, constant: Metric.subjectTopOffset),
            firstSubjectCardsHStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.horizontalMargin),
            firstSubjectCardsHStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Metric.stackViewTrailingOffset),
            
            secondSubjectLabel.topAnchor.constraint(equalTo: firstSubjectCardsHStackView.bottomAnchor, constant: Metric.secondSubjectTopOffset),
            secondSubjectLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.horizontalMargin),
            
            secondSubjectCardsHStackView.topAnchor.constraint(equalTo: secondSubjectLabel.bottomAnchor, constant: Metric.subjectTopOffset),
            secondSubjectCardsHStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.horizontalMargin),
            secondSubjectCardsHStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.horizontalMargin)
        ])
    }
}
