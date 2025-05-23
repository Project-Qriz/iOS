//
//  ExamTestFooterView.swift
//  QRIZ
//
//  Created by ch on 5/21/25.
//

import UIKit
import Combine

final class ExamTestFooterView: UIView {

    // MARK: - Properties
    private let prevButton: TestButton = TestButton(isPreviousButton: true)
    private let nextButton: TestButton = TestButton(isPreviousButton: false)
    private let pageIndicatorLabel: TestPageIndicatorLabel = .init()
    
    private let prevButtonTappedSubject: PassthroughSubject<Void, Never> = .init()
    private let nextButtonTappedSubject: PassthroughSubject<Void, Never> = .init()
    
    var prevButtonTappedPublisher: AnyPublisher<Void, Never> {
        prevButtonTappedSubject.eraseToAnyPublisher()
    }
    
    var nextButtonTappedPublisher: AnyPublisher<Void, Never> {
        nextButtonTappedSubject.eraseToAnyPublisher()
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
        pageIndicatorLabel.setCurPage(curPage: curPage)
    }
    
    func updateTotalPage(totalPage: Int) {
        pageIndicatorLabel.setTotalPage(totalPage: totalPage)
    }
    
    func updatePrevButton(isVisible: Bool) {
        prevButton.isHidden = !isVisible
    }
    
    func updateNextButton(isVisible: Bool, isTextSubmit: Bool) {
        nextButton.isHidden = !isVisible
        let nextButtonText = isTextSubmit ? "제출" : "다음"
        nextButton.setTitleText(nextButtonText)
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
        prevButton.addAction(UIAction(handler: { [weak self] _ in
            guard let self = self else { return }
            prevButtonTappedSubject.send()
        }), for: .touchUpInside)
        nextButton.addAction(UIAction(handler: { [weak self] _ in
            guard let self = self else { return }
            nextButtonTappedSubject.send()
        }), for: .touchUpInside)
    }
}

// MARK: - Auto Layout
extension ExamTestFooterView {

    private enum Layout {
        static let top: CGFloat = 17
        static let leading: CGFloat = 18
        static let trailing: CGFloat = -18
        static let width: CGFloat = 90
        static let height: CGFloat = 48
    }

    private func addViews() {
        addSubview(prevButton)
        addSubview(nextButton)
        addSubview(pageIndicatorLabel)
        
        prevButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        pageIndicatorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            prevButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Layout.leading),
            prevButton.topAnchor.constraint(equalTo: self.topAnchor, constant: Layout.top),
            prevButton.widthAnchor.constraint(equalToConstant: Layout.width),
            prevButton.heightAnchor.constraint(equalToConstant: Layout.height),
            
            nextButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: Layout.trailing),
            nextButton.topAnchor.constraint(equalTo: self.topAnchor, constant: Layout.top),
            nextButton.widthAnchor.constraint(equalToConstant: Layout.width),
            nextButton.heightAnchor.constraint(equalToConstant: Layout.height),
            
            pageIndicatorLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            pageIndicatorLabel.centerYAnchor.constraint(equalTo: nextButton.centerYAnchor)
        ])
    }
}
