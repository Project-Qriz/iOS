//
//  HomeSection.swift
//  QRIZ
//
//  Created by 김세훈 on 4/25/25.
//

import UIKit

enum HomeSection: Int, CaseIterable {
    case examSchedule
}

enum HomeSectionItem: Hashable {
    case examSchedule(ExamScheduleItem)
}

struct ExamScheduleItem: Hashable {
    let id = UUID()
    let userName: String
    let kind: Kind
    
    enum Kind: Hashable {
        case notRegistered
        case expired
        case registered(dDay: Int, detail: Detail)
        
        struct Detail: Hashable {
            let examDateText: String
            let examName: String
            let applyPeriod: String
        }
    }
}

enum HomeLayoutFactory {
    
    private enum Metric {
        static let examScheduleTopOffset: CGFloat = 24.0
        static let horizontalSpacing: CGFloat = 18.0
        static let estimated: CGFloat = 364.0
    }
    
    // MARK: - Fuinctions
    
    static func examSchedule() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(Metric.estimated)
        )
        let item  = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: Metric.examScheduleTopOffset,
            leading: Metric.horizontalSpacing,
            bottom: 0,
            trailing: Metric.horizontalSpacing
        )
        return section
    }
    
    static func makeLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { index, _ in
            guard let section = HomeSection(rawValue: index) else { return nil }
            switch section {
            case .examSchedule:
                return examSchedule()
            }
        }
    }
}
