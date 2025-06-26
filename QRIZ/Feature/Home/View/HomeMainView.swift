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
    private let entryTappedSubject = PassthroughSubject<Void, Never>()
    
    var examButtonTappedPublisher: AnyPublisher<Void, Never> {
        examButtonTappedSubject.eraseToAnyPublisher()
    }
    
    var entryTappedPublisher: AnyPublisher<Void, Never> {
        entryTappedSubject.eraseToAnyPublisher()
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
    
    private lazy var entryRegistration = UICollectionView.CellRegistration<ExamEntryCardCell, HomeSectionItem> { [weak self] cell, _, item in
        guard case .entry(let state) = item else { return }
        cell.configure(state: state)
        
        cell.contentView.gestureRecognizers?.forEach {
            cell.contentView.removeGestureRecognizer($0)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self?.didTapEntryCell))
        cell.contentView.addGestureRecognizer(tap)
    }
    
    private let dailyHeaderSupRegistration = UICollectionView.SupplementaryRegistration<DailyPlanHeaderView>(
        elementKind: UICollectionView.elementKindSectionHeader) { view, _, _ in
        }
    
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: HomeLayoutFactory.makeLayout())
        collectionView.backgroundColor = .customBlue50
        return collectionView
    }()
    
    private lazy var dataSource: UICollectionViewDiffableDataSource<HomeSection, HomeSectionItem> = {
        let ds = UICollectionViewDiffableDataSource<HomeSection, HomeSectionItem>(
            collectionView: collectionView) { [weak self] collectionView, indexPath, item in
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
        
        
        ds.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let self,
                  let section = HomeSection(rawValue: indexPath.section) else { return nil }
            
            if section == .dailyHeader,
               kind == UICollectionView.elementKindSectionHeader {
                return collectionView.dequeueConfiguredReusableSupplementary(
                    using: self.dailyHeaderSupRegistration,
                    for: indexPath)
            }
            return nil
        }
        
        return ds
    }()
    
    // MARK: - Initialize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _ = scheduleRegistration
        _ = registeredRegistration
        _ = entryRegistration
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
        snapshot.appendSections([.examSchedule, .examEntry, .dailyHeader])
        snapshot.appendItems(
            [.schedule(userName: state.userName, status: state.examStatus)],
            toSection: .examSchedule
        )
        snapshot.appendItems(
            [.entry(state.entryState)],
            toSection: .examEntry
        )
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    // MARK: - Actions
    
    @objc
    private func didTapEntryCell() {
        entryTappedSubject.send()
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

