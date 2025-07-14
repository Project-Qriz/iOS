//
//  DaySelectBottomSheetMainView.swift
//  QRIZ
//
//  Created by 김세훈 on 7/12/25.
//

import UIKit
import Combine

final class DaySelectBottomSheetMainView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let horizontalMargin: CGFloat = 18.0
        static let titleTop: CGFloat = 58.0
        static let todayTop: CGFloat = 52.0
        static let weekTop: CGFloat = 44.0
        static let nextTrailing: CGFloat = -29.0
        static let prevTrailing: CGFloat = -23.0
        static let collectionTop: CGFloat = 25.0
    }
    
    private enum Attributes {
        static let titleText: String = "Day를 설정해 주세요."
        static let todayText: String = "오늘"
        static let chevronLeft: String = "chevron.left"
        static let chevronRight: String = "chevron.right"
    }
    
    // MARK: - Properties
    
    private var totalDays: Int = 0
    private var selectedIndex: Int = 0
    private var currentWeek: Int = 0
    private let todayTapSubject = PassthroughSubject<Void, Never>()
    private let prevTapSubject = PassthroughSubject<Void, Never>()
    private let nextTapSubject = PassthroughSubject<Void, Never>()
    private let dayTapSubject = PassthroughSubject<Int, Never>()
    
    var todayTapPublisher: AnyPublisher<Void, Never> {
        todayTapSubject.eraseToAnyPublisher()
    }
    
    var prevTapPublisher: AnyPublisher<Void, Never> {
        prevTapSubject.eraseToAnyPublisher()
    }
    
    var nextTapPublisher: AnyPublisher<Void, Never> {
        nextTapSubject.eraseToAnyPublisher()
    }
    
    var dayTapPublisher: AnyPublisher<Int, Never> {
        dayTapSubject.eraseToAnyPublisher()
    }
    
    
    // MARK: - UI
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Attributes.titleText
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .coolNeutral800
        return label
    }()
    
    private lazy var todayButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.contentInsets = .init(top: 8, leading: 10, bottom: 8, trailing: 10)
        config.baseBackgroundColor = .clear
        config.baseForegroundColor = .coolNeutral600
        config.background.strokeColor = .coolNeutral200
        config.background.strokeWidth = 1
        config.title = Attributes.todayText
        config.titleTextAttributesTransformer = .init { attr in
            var a = attr
            a.foregroundColor = .coolNeutral600
            a.font = .systemFont(ofSize: 12, weight: .regular)
            return a
        }
        let button = UIButton(configuration: config)
        
        button.addAction(UIAction { [weak self] _ in
            self?.todayTapSubject.send()
        }, for: .touchUpInside)
        return button
    }()
    
    private let weekLabel: UILabel = {
        let label = UILabel()
        label.text = "1주차"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .coolNeutral600
        return label
    }()
    
    private lazy var prevButton: UIButton = {
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        let image = UIImage(systemName: Attributes.chevronLeft, withConfiguration: config)
        let button = UIButton(type: .system)
        button.setImage(image, for: .normal)
        button.tintColor = .coolNeutral200
        
        button.addAction(UIAction { [weak self] _ in
            self?.prevTapSubject.send()
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var nextButton: UIButton = {
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        let image = UIImage(systemName: Attributes.chevronRight, withConfiguration: config)
        let button = UIButton(type: .system)
        button.setImage(image, for: .normal)
        button.tintColor = .coolNeutral800
        
        button.addAction(UIAction { [weak self] _ in
            self?.nextTapSubject.send()
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = .zero
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 8
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(DayCell.self, forCellWithReuseIdentifier: String(describing: DayCell.self))
        cv.backgroundColor = .white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let columns: CGFloat = 4
        let spacing = flow.minimumInteritemSpacing
        let sideInset = Metric.horizontalMargin
        let totalSpacing = spacing * (columns - 1)
        let availableWidth = collectionView.bounds.width - sideInset - totalSpacing
        let cellWidth = floor(availableWidth / columns)
        flow.itemSize = CGSize(width: cellWidth, height: 36)
    }
    
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
    
    func updateWeek(_ week: Int) {
        currentWeek = week - 1
        weekLabel.text = "\(week)주차"
    }
    
    func updateArrows(prevEnabled: Bool, nextEnabled: Bool) {
        prevButton.isEnabled = prevEnabled
        nextButton.isEnabled = nextEnabled
        prevButton.tintColor = prevEnabled ? .coolNeutral800 : .coolNeutral200
        nextButton.tintColor = nextEnabled ? .coolNeutral800 : .coolNeutral200
    }
    
    func reloadCollectionView(selected: Int, totalDays: Int) {
        selectedIndex = selected
        self.totalDays = totalDays
        collectionView.reloadData()
    }
}

// MARK: - Layout Setup

extension DaySelectBottomSheetMainView {
    private func addSubviews() {
        [
            titleLabel,
            todayButton,
            weekLabel,
            prevButton,
            nextButton,
            collectionView
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        [
            titleLabel,
            todayButton,
            weekLabel,
            prevButton,
            nextButton,
            collectionView
        ].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: safeAreaLayoutGuide.topAnchor,
                constant: Metric.titleTop
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Metric.horizontalMargin
            ),
            
            todayButton.topAnchor.constraint(
                equalTo: safeAreaLayoutGuide.topAnchor,
                constant: Metric.todayTop
            ),
            todayButton.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -Metric.horizontalMargin
            ),
            
            weekLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: Metric.weekTop
            ),
            weekLabel.leadingAnchor
                .constraint(equalTo: titleLabel.leadingAnchor),
            
            nextButton.topAnchor.constraint(
                equalTo: weekLabel.topAnchor
            ),
            nextButton.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: Metric.nextTrailing
            ),
            
            prevButton.topAnchor.constraint(
                equalTo: weekLabel.topAnchor
            ),
            prevButton.trailingAnchor.constraint(
                equalTo: nextButton.leadingAnchor,
                constant: Metric.prevTrailing
            ),
            
            collectionView.topAnchor.constraint(
                equalTo: prevButton.bottomAnchor,
                constant: Metric.collectionTop
            ),
            collectionView.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Metric.horizontalMargin
            ),
            collectionView.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -Metric.horizontalMargin
            ),
            collectionView.bottomAnchor.constraint(
                equalTo: bottomAnchor
            )
        ])
    }
}

extension DaySelectBottomSheetMainView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let start = currentWeek * 7
        return min(7, 30 - start)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: DayCell.self),
            for: indexPath) as? DayCell else { return UICollectionViewCell() }
        let globalDay = currentWeek * 7 + indexPath.item
        let isSelected = globalDay == selectedIndex
        cell.configure(title: "Day\(globalDay + 1)", selected: isSelected)
        return cell
    }
    
    func collectionView(_ cv: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let globalDay = currentWeek * 7 + indexPath.item
        dayTapSubject.send(globalDay)
    }
}
