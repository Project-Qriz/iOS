//
//  WrongQuestionSegment.swift
//  QRIZ
//
//  Created by 이창현 on 1/14/25.
//

import UIKit

final class WrongQuestionSegment: UIView {
    
    // MARK: - Properties
    private let segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.insertSegment(withTitle: "데일리", at: 0, animated: true)
        segmentedControl.insertSegment(withTitle: "모의고사", at: 1, animated: true)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = .white
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.coolNeutral400, .font: UIFont.systemFont(ofSize: 16, weight: .bold)], for: .normal)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.coolNeutral800, .font: UIFont.systemFont(ofSize: 16, weight: .bold)], for: .selected)
        segmentedControl.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        segmentedControl.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        
        return segmentedControl
    }()
    private let dailyTestUnderline: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    private let mockExamUnderline: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    // MARK: - Initializer
    init() {
        super.init(frame: .zero)
        addViews()

    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func setUnderlineState(_ isDailyTestClicked: Bool) {
        if isDailyTestClicked {
            dailyTestUnderline.isHidden = false
            mockExamUnderline.isHidden = true
        } else {
            dailyTestUnderline.isHidden = true
            mockExamUnderline.isHidden = false
        }
    }
    
}

// MARK: - Auto Layout, View settings
extension WrongQuestionSegment {
    
    private func addViews() {
        
        addSubview(segmentedControl)
        addSubview(dailyTestUnderline)
        addSubview(mockExamUnderline)
        
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        dailyTestUnderline.translatesAutoresizingMaskIntoConstraints = false
        mockExamUnderline.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            segmentedControl.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            segmentedControl.topAnchor.constraint(equalTo: self.topAnchor),
            segmentedControl.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            dailyTestUnderline.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            dailyTestUnderline.trailingAnchor.constraint(equalTo: self.centerXAnchor),
            dailyTestUnderline.bottomAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            dailyTestUnderline.heightAnchor.constraint(equalToConstant: 3),
            
            mockExamUnderline.leadingAnchor.constraint(equalTo: self.centerXAnchor),
            mockExamUnderline.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            mockExamUnderline.bottomAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            dailyTestUnderline.heightAnchor.constraint(equalToConstant: 3)
        ])
    }
    
    private func setUnderlinesInitState() {
        bringSubviewToFront(dailyTestUnderline)
        bringSubviewToFront(mockExamUnderline)
        
        mockExamUnderline.isHidden = true
    }
}

