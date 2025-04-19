//
//  ChapterDetailMainView.swift
//  QRIZ
//
//  Created by 김세훈 on 4/18/25.
//

import UIKit

final class ChapterDetailMainView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let imageViewTopOffset: CGFloat = 24.0
        static let imageViewWidth: CGFloat = 105.0
        static let imageViewHeight: CGFloat = 164.0
        static let menuListTopOffset: CGFloat = 32.0
        static let contentMargin: CGFloat = 18.0
    }
    
    private enum Attributes {
    }
    
    // MARK: - Properties
    
    
    // MARK: - UI
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView = UIView()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .dataModelAndSQL
        return imageView
    }()
    
    let menuListView = MenuListView()
    
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
        self.backgroundColor = .customBlue50
    }
    
    func configure(with chapter: Chapter, items: [ConceptItem]) {
        imageView.image = UIImage(named: chapter.assetName)
        menuListView.configure(with: items)
    }
}

// MARK: - Layout Setup

extension ChapterDetailMainView {
    private func addSubviews() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(imageView)
        contentView.addSubview(menuListView)
    }
    
    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        menuListView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            [
                scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
                
                contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
                contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
                contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
                contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
                
                imageView.topAnchor.constraint(
                    equalTo: contentView.safeAreaLayoutGuide.topAnchor,
                    constant: Metric.imageViewTopOffset
                ),
                imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                imageView.widthAnchor.constraint(equalToConstant: Metric.imageViewWidth),
                imageView.heightAnchor.constraint(equalToConstant: Metric.imageViewHeight),
                
                menuListView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Metric.menuListTopOffset),
                menuListView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metric.contentMargin),
                menuListView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Metric.contentMargin),
                menuListView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Metric.contentMargin)
            ]
        )
    }
}
