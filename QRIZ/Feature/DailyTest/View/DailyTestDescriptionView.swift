//
//  DailyTestDescriptionView.swift
//  QRIZ
//
//  Created by 이창현 on 4/3/25.
//

import UIKit

final class DailyTestDescriptionView: UIView {
    
    // MARK: - Properties
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .black
        return label
    }()
    
    // MARK: - Initializers
    init() {
        super.init(frame: .zero)
        setBorder()
        addViews()
        setAttributedText("""
        [업무상황]
        1. 고객이 상품을 주문한다.
        2. 한 번의 주문에 여러 상품을 담을 수 있다.
        3. 상품의 재고는 실시간으로 관리되어야 한다.
        4. 주문 상태는 '주문', '결제', '배송', '완료'로 관리된다.
        """)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Methods
    private func setBorder() {
        layer.cornerRadius = 8
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.coolNeutral200.cgColor
    }
    
    private func setAttributedText(_ text: String) {
        label.attributedText = formattedText(text)
    }
    
    private func formattedText(_ text: String) -> NSMutableAttributedString {
        let attributedText = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedText.length))
        return attributedText
    }
}

extension DailyTestDescriptionView {
    private func addViews() {
        addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
}
