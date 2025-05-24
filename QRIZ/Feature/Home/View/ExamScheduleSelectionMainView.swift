//
//  ExamScheduleSelectionMainView.swift
//  QRIZ
//
//  Created by 김세훈 on 5/2/25.
//

import UIKit
import Combine

final class ExamScheduleSelectionMainView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let defaultMargin: CGFloat = 18.0
        static let titleLabelBottomOffset: CGFloat = -12.0
    }
    
    private enum Attributes {
        static let titleText: String = "시험 등록"
    }
    
    // MARK: - Properties
    
    private let examTappedSubject = PassthroughSubject<Int, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    var examTappedPublisher: AnyPublisher<Int, Never> {
        examTappedSubject.eraseToAnyPublisher()
    }
    
    // MARK: - UI
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Attributes.titleText
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .coolNeutral800
        return label
    }()
    
    private let listVStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
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
        backgroundColor = .white
    }
    
    func updateExamList(rows: [ExamRowState]) {
        cancellables.removeAll()
        listVStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        rows.forEach { state in
            let row = ExamInfoRowView()
            row.configure(with: state)
            listVStackView.addArrangedSubview(row)
            
            guard state.isExpired == false else { return }
            
            row.tapGestureEndedPublisher()
                .sink { [weak self] in
                    self?.examTappedSubject.send(state.id)
                }
                .store(in: &cancellables)
        }
    }
}

// MARK: - Layout Setup

extension ExamScheduleSelectionMainView {
    private func addSubviews() {
        [titleLabel, listVStackView].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        listVStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.defaultMargin),
            titleLabel.bottomAnchor.constraint(equalTo: listVStackView.topAnchor, constant: Metric.titleLabelBottomOffset),
            
            listVStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            listVStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            listVStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}


