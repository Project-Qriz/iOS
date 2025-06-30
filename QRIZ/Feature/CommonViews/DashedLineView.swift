//
//  DashedLineView.swift
//  QRIZ
//
//  Created by 김세훈 on 6/30/25.
//

import UIKit

/// 가로 점선을 그려 주는 뷰
final class DashedLineView: UIView {

    private enum Metric {
        static let lineWidth: CGFloat = 1
        static let dashPattern: [NSNumber] = [4, 4]
    }

    private let shapeLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayer()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayer()
    }

    private func setupLayer() {
        shapeLayer.strokeColor = UIColor.customBlue100.cgColor
        shapeLayer.lineWidth = Metric.lineWidth
        shapeLayer.lineDashPattern = Metric.dashPattern
        shapeLayer.fillColor = nil
        layer.addSublayer(shapeLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        shapeLayer.frame = bounds
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: bounds.midY))
        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.midY))
        shapeLayer.path = path.cgPath
    }
}
