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
    private let nextButton: TestButton = TestButton(isPreviousButton: false)
    private let pageIndicatorLabel: TestPageIndicatorLabel = .init()
    
    let input: PassthroughSubject<DailyTestViewModel.Input, Never> = .init()
    
    // MARK: - Initializers
    init() {
        super.init(frame: .zero)
        setupUI()
        addViews()
        addButtonAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Methods
    func updateCurPage(curPage: Int) {
        pageIndicatorLabel.setCurPage(curPage: curPage)
    }
    
    func updateTotalPage(totalPage: Int) {
        pageIndicatorLabel.setTotalPage(totalPage: totalPage)
    }
    
    func setButtonsVisibility(isVisible: Bool) {
        nextButton.isHidden = !isVisible
    }
    
    func alterButtonText() {
        nextButton.setTitleText("제출")
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
        nextButton.addAction(UIAction(handler: { [weak self] _ in
            guard let self = self else { return }
            self.input.send(.nextButtonClicked)
        }), for: .touchUpInside)
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
            nextButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -18),
            nextButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 17),
            nextButton.widthAnchor.constraint(equalToConstant: 90),
            nextButton.heightAnchor.constraint(equalToConstant: 48),
            
            pageIndicatorLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            pageIndicatorLabel.centerYAnchor.constraint(equalTo: nextButton.centerYAnchor)
        ])
    }
}
