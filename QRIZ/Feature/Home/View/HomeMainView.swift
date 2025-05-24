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
    
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: HomeLayoutFactory.makeLayout())
        collectionView.backgroundColor = .customBlue50
        
        collectionView.register(
            ExamScheduleCardCell.self,
            forCellWithReuseIdentifier: String(describing: ExamScheduleCardCell.self)
        )
        
        collectionView.register(
            ExamScheduleRegisteredCell.self,
            forCellWithReuseIdentifier: String(describing: ExamScheduleRegisteredCell.self)
        )
        
        return collectionView
    }()
    
    private lazy var dataSource = UICollectionViewDiffableDataSource<
        HomeSection, HomeSectionItem>(collectionView: collectionView) { [weak self]
            collectionView, indexPath, item in
            guard let self else { return UICollectionViewCell() }
            
            switch item {
            case let .examSchedule(model):
                switch model.kind {
                case .notRegistered, .expired:
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: String(describing: ExamScheduleCardCell.self),
                        for: indexPath
                    ) as! ExamScheduleCardCell
                    cell.configure(userName: model.userName,
                                   statusText: model.kind == .notRegistered
                                   ? "등록된 일정이 없어요."
                                   : "등록했던 시험일이 지났어요.")
                    
                    cell.buttonTapPublisher
                        .sink { [weak self] in self?.examButtonTappedSubject.send() }
                        .store(in: &cell.cancellables)
                    return cell
                    
                case let .registered(dDay, detail):
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: String(describing: ExamScheduleRegisteredCell.self),
                        for: indexPath
                    ) as! ExamScheduleRegisteredCell
                    cell.configure(userName: model.userName,
                                   dday: dDay,
                                   detail: detail)
                    cell.buttonTapPublisher
                        .sink { [weak self] in self?.examButtonTappedSubject.send() }
                        .store(in: &cell.cancellables)
                    return cell
                }
            }
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
        backgroundColor = .customBlue50
    }
    
    func applySnapshot(registered item: ExamScheduleItem) {
        var snapshot = NSDiffableDataSourceSnapshot<HomeSection, HomeSectionItem>()
        snapshot.appendSections([.examSchedule])
        snapshot.appendItems([.examSchedule(item)], toSection: .examSchedule)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func applySnapshot(notRegisteredFor user: String) {
        let item = ExamScheduleItem(userName: user, kind: .notRegistered)
        var snapshot = NSDiffableDataSourceSnapshot<HomeSection, HomeSectionItem>()
        snapshot.appendSections([.examSchedule])
        snapshot.appendItems([.examSchedule(item)], toSection: .examSchedule)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func applySnapshot(expiredFor user: String) {
        let item = ExamScheduleItem(userName: user, kind: .expired)
        var snapshot = NSDiffableDataSourceSnapshot<HomeSection, HomeSectionItem>()
        snapshot.appendSections([.examSchedule])
        snapshot.appendItems([.examSchedule(item)], toSection: .examSchedule)
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

