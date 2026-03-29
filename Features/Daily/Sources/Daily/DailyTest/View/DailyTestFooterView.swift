//
//  DailyTestFooterView.swift
//  QRIZ
//
//  Created by 이창현 on 4/1/25.
//

import UIKit
import DesignSystem
import Combine
import ExamKit

final class DailyTestFooterView: UIView {

    // MARK: - enum

    private enum Metric {
        static let trailingPadding: CGFloat = 18
        static let topPadding: CGFloat = 17
        static let buttonWidth: CGFloat = 90
        static let buttonHeight: CGFloat = 48
    }

    // MARK: - Properties
    
    private let nextButton: TestButton = .init(isPreviousButton: false)
    private let pageIndicatorLabel: TestPageIndicatorLabel = .init()
    private let nextButtonSubject = PassthroughSubject<Void, Never>()
    var nextButtonTappedPublisher: AnyPublisher<Void, Never> {
        nextButtonSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initializers
    
    init() {
        super.init(frame: .zero)
        setupUI()
        addViews()
        addButtonAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("no initializer for coder: DailyTestFooterView")
    }
    
    // MARK: - Methods
    
    func updateCurPage(curPage: Int) {
        pageIndicatorLabel.setCurrentPage(curPage)
    }

    func updateTotalPage(totalPage: Int) {
        pageIndicatorLabel.setTotalPage(totalPage)
    }
    
    func setButtonsVisibility(isVisible: Bool) {
        nextButton.isHidden = !isVisible
    }
    
    func alterButtonText() {
        nextButton.updateTitle("제출")
    }
    
    private func setupUI() {
        backgroundColor = .white
        layer.shadowColor = UIColor.customBlue100.cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 16
        layer.borderColor = UIColor.customBlue100.cgColor
        layer.borderWidth = 1
    }
    
    private func addButtonAction() {
        nextButton.addAction(UIAction { [weak self] _ in
            self?.nextButtonSubject.send()
        }, for: .touchUpInside)
    }
}

// MARK: - Auto Layout

extension DailyTestFooterView {
    private func addViews() {
        addSubview(nextButton)
        addSubview(pageIndicatorLabel)
        
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        pageIndicatorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nextButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.trailingPadding),
            nextButton.topAnchor.constraint(equalTo: topAnchor, constant: Metric.topPadding),
            nextButton.widthAnchor.constraint(equalToConstant: Metric.buttonWidth),
            nextButton.heightAnchor.constraint(equalToConstant: Metric.buttonHeight),

            pageIndicatorLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            pageIndicatorLabel.centerYAnchor.constraint(equalTo: nextButton.centerYAnchor)
        ])
    }
}
