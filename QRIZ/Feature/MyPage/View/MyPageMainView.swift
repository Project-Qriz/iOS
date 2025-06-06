//
//  MyPageMainView.swift
//  QRIZ
//
//  Created by 김세훈 on 5/31/25.
//

import UIKit
import Combine

final class MyPageMainView: UIView {
    
    // MARK: - Properties
    
    // MARK: - UI
    
    private let profileRegistration = UICollectionView.CellRegistration<ProfileCell, String>
    { cell, _, userName in cell.configure(with: userName) }
    
    private let quickActionRegistration = UICollectionView.CellRegistration<QuickActionsCell, Void>
    { _,_,_ in }
    
    private let supportHeaderRegistration = UICollectionView.CellRegistration<SupportHeaderCell, Void>
    { _, _, _ in }
    
    private let supportMenuRegistration = UICollectionView.CellRegistration<SupportMenuCell, MyPageSectionItem.SupportMenu> {
        cell, _, menu in cell.configure(title: menu.rawValue) }
    
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: MyPageLayoutFactory.makeLayout()
        )
        collectionView.backgroundColor = .customBlue50
        return collectionView
    }()
    
    private lazy var dataSource = UICollectionViewDiffableDataSource<MyPageSection, MyPageSectionItem>(
        collectionView: collectionView) { [weak self] collectionView, indexPath, item in
            guard let self else { return UICollectionViewCell() }
            
            switch item {
            case .profile(let name):
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.profileRegistration,
                    for: indexPath,
                    item: name
                )
                
            case .quickActions:
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.quickActionRegistration,
                    for: indexPath,
                    item: ()
                )
                
            case .supportHeader:
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.supportHeaderRegistration,
                    for: indexPath,
                    item: ()
                )
                
            case .supportMenu(let menu):
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.supportMenuRegistration,
                    for: indexPath,
                    item: menu
                )
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
    
    private func applyInitialSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<MyPageSection, MyPageSectionItem>()
        snapshot.appendSections([.profile, .quickActions, .support])
        snapshot.appendItems([.profile(userName: "김세훈")], toSection: .profile)
        snapshot.appendItems([.quickActions], toSection: .quickActions)
        snapshot.appendItems(
            [.supportHeader,
             .supportMenu(.termsOfService),
             .supportMenu(.privacyPolicy),
             .supportMenu(.versionInfo)], toSection: .support
        )
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - Layout Setup

extension MyPageMainView {
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

