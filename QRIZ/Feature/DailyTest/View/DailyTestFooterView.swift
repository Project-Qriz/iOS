//
//  DailyTestFooterView.swift
//  QRIZ
//
//  Created by 이창현 on 4/1/25.
//

import UIKit
import Combine

final class DailyTestFooterView: UIView {
    
    // MARK: - Properties
    private let previousButton: TestButton = TestButton(isPreviousButton: true)
    private let nextButton: TestButton = TestButton(isPreviousButton: true)
    private let pageIndicatorLabel: TestPageIndicatorLabel = .init()
    
    // Combine 추가 자리
    
    // MARK: - Initializers
    init() {
        super.init(frame: .zero)
        setupUI()
        addViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Methods
    func updatePage(curPage: Int, totalPage: Int) {
        pageIndicatorLabel.setPages(curPage: curPage, totalPage: totalPage)
    }
    
    func setButtonsVisibility(isFirstQuestion: Bool, isOptionSelected: Bool = false) {
        if isFirstQuestion {
            previousButton.isHidden = true
            nextButton.isHidden = !isOptionSelected
        } else {
            previousButton.isHidden = false
            nextButton.isHidden = false
        }
    }
    
    private func setupUI() {
        backgroundColor = .white
        layer.shadowColor = UIColor.customBlue100.cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 16
    }
}

// MARK: - Auto Layout
extension DailyTestFooterView {
    private func addViews() {
        addSubview(previousButton)
        addSubview(nextButton)
        addSubview(pageIndicatorLabel)
        
        previousButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        pageIndicatorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            previousButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 18),
            previousButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -30),
            previousButton.widthAnchor.constraint(equalToConstant: 90),
            previousButton.heightAnchor.constraint(equalToConstant: 48),
            
            nextButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -18),
            nextButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -30),
            nextButton.widthAnchor.constraint(equalToConstant: 90),
            nextButton.heightAnchor.constraint(equalToConstant: 48),
            
            pageIndicatorLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            pageIndicatorLabel.centerYAnchor.constraint(equalTo: previousButton.centerYAnchor)
        ])
    }
}
