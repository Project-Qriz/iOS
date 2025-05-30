//
//  MyPageSection.swift
//  QRIZ
//
//  Created by 김세훈 on 5/31/25.
//

import UIKit

enum MyPageSection: Int, CaseIterable {
    case profile
}

enum MyPageSectionItem: Hashable {
    case profile(userName: String)
}

enum MyPageLayoutFactory {
    
    private enum Metric {
        static let profileTopOffset: CGFloat = 24.0
        static let horizontalSpacing: CGFloat = 18.0
        static let profileEstimated: CGFloat = 90.0
    }
    
    // MARK: - Functions
    
    static func profile() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(Metric.profileEstimated)
        )
        let item  = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: Metric.profileTopOffset,
            leading: Metric.horizontalSpacing,
            bottom: 0,
            trailing: Metric.horizontalSpacing
        )
        return section
    }
    
    static func makeLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { index, _ in
            guard let section = MyPageSection(rawValue: index) else { return nil }
            switch section {
            case .profile: return profile()
            }
        }
    }
}
