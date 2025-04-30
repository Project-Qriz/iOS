//
//  HomeMainView.swift
//  QRIZ
//
//  Created by 김세훈 on 4/25/25.
//

import UIKit

final class HomeMainView: UIView {
    
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
    
    private lazy var dataSource = UICollectionViewDiffableDataSource<HomeSection, HomeSectionItem>(collectionView: collectionView) {
            collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case let .examSchedule(model):
                
                switch model.kind {
                case .notRegistered:
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: String(describing: ExamScheduleCardCell.self),
                        for: indexPath
                    ) as? ExamScheduleCardCell else { return UICollectionViewCell() }
                    
                    cell.configure(userName: model.userName, statusText: "등록된 일정이 없어요.")
                    return cell
                    
                case .expired:
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: String(describing: ExamScheduleCardCell.self),
                        for: indexPath
                    ) as? ExamScheduleCardCell else { return UICollectionViewCell() }
                    
                    cell.configure(userName: model.userName, statusText: "등록했던 시험일이 지났어요.")
                    return cell
                    
                case let .registered(dDay, detail):
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: String(describing: ExamScheduleRegisteredCell.self),
                        for: indexPath
                    ) as? ExamScheduleRegisteredCell else { return UICollectionViewCell() }
                    
                    cell.configure(userName: model.userName, dday: dDay, detail: detail)
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
        applyInitialSnapshot()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    private func setupUI() {
        backgroundColor = .customBlue50
    }
    
    func applyInitialSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<HomeSection, HomeSectionItem>()
        snapshot.appendSections([.examSchedule])
        
        let notReg = ExamScheduleItem(
            userName: "채영",
            kind: .notRegistered
        )
        
        let expired = ExamScheduleItem(
            userName: "채영",
            kind: .expired
        )
        
        let detail = ExamScheduleItem.Kind.Detail(
            examDateText: "시험일: 3월9일(토)",
            examName: "제 52회 SQL 개발자",
            applyPeriod: "접수기간: 01.29(월) 10:00 ~ 02.02(금) 18:00"
        )
        
        let registered = ExamScheduleItem(
            userName: "채영",
            kind: .registered(dDay: 24, detail: detail)
        )
        
        snapshot.appendItems([
            .examSchedule(registered)
        ], toSection: .examSchedule)
        
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

