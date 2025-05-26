//
//  HomeSection.swift
//  QRIZ
//
//  Created by 김세훈 on 4/25/25.
//

import UIKit

enum HomeSection: Int, CaseIterable {
    case examSchedule
    case examEntry
}

enum HomeSectionItem: Hashable {
    case examSchedule(ExamScheduleItem)
    case examEntry(ExamEntryCardCell.State)
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
        static let examScheduleEstimated: CGFloat = 364.0
        static let examScheduleTopOffset: CGFloat = 24.0
        static let horizontalSpacing: CGFloat = 18.0
        
        static let examEntryEstimated: CGFloat = 106.0
        static let examEntryTopOffset: CGFloat = 40.0
    }
    
    // MARK: - Functions
    
    private static func examSchedule() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(Metric.examScheduleEstimated)
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
    
    private static func examEntry() -> NSCollectionLayoutSection {
        let size = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(Metric.examEntryEstimated)
        )
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: size, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: Metric.examEntryTopOffset,
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
            case .examSchedule: return examSchedule()
            case .examEntry: return examEntry()
            }
        }
    }
}
