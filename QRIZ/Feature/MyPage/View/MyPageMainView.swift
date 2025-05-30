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
    
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: MyPageLayoutFactory.makeLayout())
        collectionView.backgroundColor = .customBlue50
        
        collectionView.register(
            ProfileCell.self,
            forCellWithReuseIdentifier: String(describing: ProfileCell.self)
        )
        
        return collectionView
    }()
    
    private lazy var dataSource = UICollectionViewDiffableDataSource<
        MyPageSection, MyPageSectionItem>(collectionView: collectionView) { [weak self]
            collectionView, indexPath, item in
            guard let self else { return UICollectionViewCell() }
            
            switch item {
            case .profile(let userName):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: String(describing: ProfileCell.self),
                    for: indexPath
                ) as? ProfileCell else { return UICollectionViewCell() }
                cell.configure(with: userName)
                return cell
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
        snapshot.appendSections([.profile])
        snapshot.appendItems([.profile(userName: "김세훈")], toSection: .profile)
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

