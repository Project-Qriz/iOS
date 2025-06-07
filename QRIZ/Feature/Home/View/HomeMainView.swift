//
//  HomeMainView.swift
//  QRIZ
//
//  Created by 김세훈 on 4/25/25.
//

import UIKit
import Combine

final class HomeMainView: UIView {
    
    // MARK: - Properties
    
    private let examButtonTappedSubject = PassthroughSubject<Void, Never>()
    
    var examButtonTappedPublisher: AnyPublisher<Void, Never> {
        examButtonTappedSubject.eraseToAnyPublisher()
    }
    
    // MARK: - UI
    
    private lazy var scheduleRegistration = UICollectionView.CellRegistration<ExamScheduleCardCell, HomeSectionItem>
    { cell, _, item in
        guard case let .schedule(userName, status) = item else { return }
        let statusText: String = {
            switch status {
            case .none: return "등록된 일정이 없어요."
            case .expired: return "등록했던 시험일이 지났어요."
            default: return ""
            }
        }()
        cell.configure(userName: userName, statusText: statusText)
        cell.buttonTapPublisher
            .sink { [weak self] in self?.examButtonTappedSubject.send() }
            .store(in: &cell.cancellables)
    }
    
    private lazy var registeredRegistration = UICollectionView.CellRegistration<ExamScheduleRegisteredCell, HomeSectionItem>
    { cell, _, item in
    guard case let .schedule(userName, .registered(dDay, detail)) = item else { return }
        
    cell.configure(userName: userName, dday: dDay, detail: detail)
    cell.buttonTapPublisher
        .sink { [weak self] in self?.examButtonTappedSubject.send() }
        .store(in: &cell.cancellables)
}
    
    private let entryRegistration = UICollectionView.CellRegistration<ExamEntryCardCell, HomeSectionItem> { cell, _, item in
        guard case let .entry(state) = item else { return }
        cell.configure(state: state)
    }

    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: HomeLayoutFactory.makeLayout())
        collectionView.backgroundColor = .customBlue50
        return collectionView
    }()
    
    private lazy var dataSource = UICollectionViewDiffableDataSource<HomeSection, HomeSectionItem>(collectionView: collectionView)
    { [weak self] collectionView, indexPath, item in
        guard let self = self else { return UICollectionViewCell() }
        switch item {
        case .schedule:
            switch item {
            case .schedule(_, .registered):
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.registeredRegistration,
                    for: indexPath,
                    item: item
                )
            default:
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.scheduleRegistration,
                    for: indexPath,
                    item: item
                )
            }
        case .entry:
            return collectionView.dequeueConfiguredReusableCell(
                using: self.entryRegistration,
                for: indexPath,
                item: item
            )
        }
    }
    
    // MARK: - Initialize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _ = scheduleRegistration
        _ = registeredRegistration
        addSubviews()
        setupConstraints()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    private func setupUI() {
        backgroundColor = .customBlue50
    }
    
    func apply(_ state: HomeState) {
        var snapshot = NSDiffableDataSourceSnapshot<HomeSection, HomeSectionItem>()
        snapshot.appendSections([.examSchedule, .examEntry])
        snapshot.appendItems([.schedule(userName: state.userName, status: state.examStatus)], toSection: .examSchedule)
        snapshot.appendItems([.entry(state.entryState)], toSection: .examEntry)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - Layout Setup

extension HomeMainView {
    private func addSubviews() {
        addSubview(collectionView)
    }
    
    private func setupConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

